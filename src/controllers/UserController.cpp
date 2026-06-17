#include "UserController.h"
#include "../core/DatabaseManager.h"

#include <QCryptographicHash>
#include <QDateTime>
#include <QRandomGenerator>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QRegularExpression>

UserController::UserController(DatabaseManager *database, QObject *parent)
    : QObject(parent)
    , m_database(database)
{
    provisionInitialAdminFromEnvironment();
}

QString UserController::currentUser() const { return m_currentUser; }
QString UserController::currentRole() const { return m_currentRole; }
bool UserController::loggedIn() const { return !m_currentUser.isEmpty(); }
int UserController::lockTimeoutSeconds() const { return m_lockTimeoutSeconds; }

QString UserController::createSalt()
{
    QByteArray bytes(16, Qt::Uninitialized);
    auto *begin = reinterpret_cast<quint32 *>(bytes.data());
    QRandomGenerator::system()->generate(begin, begin + bytes.size() / static_cast<int>(sizeof(quint32)));
    return QString::fromLatin1(bytes.toHex());
}

QString UserController::hashPin(const QString &pin, const QString &salt)
{
    QByteArray digest = (salt + QStringLiteral(":") + pin).toUtf8();
    constexpr int iterations = 120000;
    for (int i = 0; i < iterations; ++i)
        digest = QCryptographicHash::hash(digest + salt.toUtf8(), QCryptographicHash::Sha256);
    return QString::fromLatin1(digest.toHex());
}

bool UserController::pinFormatValid(const QString &pin)
{
    static const QRegularExpression pattern(QStringLiteral("^\\d{6,12}$"));
    return pattern.match(pin).hasMatch();
}

bool UserController::roleValid(const QString &role)
{
    return role == QStringLiteral("Admin")
        || role == QStringLiteral("Service")
        || role == QStringLiteral("Doctor")
        || role == QStringLiteral("Nurse");
}

int UserController::roleLevel(const QString &role)
{
    if (role == QStringLiteral("Admin"))   return 4;
    if (role == QStringLiteral("Service")) return 3;
    if (role == QStringLiteral("Doctor"))  return 2;
    if (role == QStringLiteral("Nurse"))   return 1;
    return 0;
}

bool UserController::login(const QString &username, const QString &pin)
{
    if (!m_database)
        return false;

    const QDateTime nowUtc = QDateTime::currentDateTimeUtc();
    QSqlQuery stateQuery(QSqlDatabase::database(QStringLiteral("SmartVentilatorConnection")));
    stateQuery.prepare(QStringLiteral(
        "SELECT failed_attempts, locked_until FROM users WHERE username = ?"));
    stateQuery.addBindValue(username);
    if (stateQuery.exec() && stateQuery.next()) {
        const int persistedFailures = stateQuery.value(0).toInt();
        const QString lockedUntilText = stateQuery.value(1).toString();
        if (persistedFailures > 0)
            m_failedAttempts.insert(username, persistedFailures);
        if (!lockedUntilText.isEmpty())
            m_lockedUntilUtc.insert(username, QDateTime::fromString(lockedUntilText, Qt::ISODate));
    }

    const QDateTime lockedUntil = m_lockedUntilUtc.value(username);
    if (lockedUntil.isValid() && lockedUntil > nowUtc) {
        const QString reason = QStringLiteral("Account locked. Try again in %1 seconds")
            .arg(nowUtc.secsTo(lockedUntil));
        emit loginFailed(reason);
        if (m_database)
            m_database->logEvent(QStringLiteral("Security"),
                                 QStringLiteral("Locked login attempt for user: ") + username,
                                 QStringLiteral("Blocked"));
        return false;
    }

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "SELECT role, full_name, pin_hash, salt FROM users WHERE username = ?"));
    query.addBindValue(username);

    if (!query.exec() || !query.next()) {
        const int failures = m_failedAttempts.value(username, 0) + 1;
        m_failedAttempts.insert(username, failures);
        QDateTime lockedUntilToPersist;
        if (failures >= 5) {
            lockedUntilToPersist = nowUtc.addSecs(300);
            m_lockedUntilUtc.insert(username, lockedUntilToPersist);
            m_failedAttempts.insert(username, 0);
        }
        emit loginFailed(QStringLiteral("Invalid username or PIN"));
        if (m_database)
            m_database->logEvent(QStringLiteral("Security"),
                QStringLiteral("Failed login attempt for user: ") + username);
        return false;
    }

    const QString storedHash = query.value(2).toString();
    const QString salt = query.value(3).toString();
    const bool legacyMatch = salt.isEmpty()
        && storedHash == QString::fromLatin1(QCryptographicHash::hash(pin.toUtf8(), QCryptographicHash::Sha256).toHex());
    const bool saltedMatch = !salt.isEmpty() && storedHash == hashPin(pin, salt);
    if (!legacyMatch && !saltedMatch) {
        const int failures = m_failedAttempts.value(username, 0) + 1;
        m_failedAttempts.insert(username, failures);
        QDateTime lockedUntilToPersist;
        if (failures >= 5) {
            lockedUntilToPersist = nowUtc.addSecs(300);
            m_lockedUntilUtc.insert(username, lockedUntilToPersist);
            m_failedAttempts.insert(username, 0);
        }
        persistFailedLogin(username, failures >= 5 ? 0 : failures, lockedUntilToPersist);
        emit loginFailed(QStringLiteral("Invalid username or PIN"));
        if (m_database)
            m_database->logEvent(QStringLiteral("Security"),
                QStringLiteral("Failed login attempt for user: ") + username);
        return false;
    }

    if (legacyMatch) {
        const QString newSalt = createSalt();
        QSqlQuery migrate(QSqlDatabase::database(QStringLiteral("SmartVentilatorConnection")));
        migrate.prepare(QStringLiteral("UPDATE users SET pin_hash = ?, salt = ? WHERE username = ?"));
        migrate.addBindValue(hashPin(pin, newSalt));
        migrate.addBindValue(newSalt);
        migrate.addBindValue(username);
        if (!migrate.exec())
            qWarning() << "Failed to migrate legacy PIN hash:" << migrate.lastError().text();
    }

    m_currentUser = username;
    m_currentRole = query.value(0).toString();
    m_failedAttempts.remove(username);
    m_lockedUntilUtc.remove(username);
    clearFailedLogin(username);
    emit sessionChanged();

    if (m_database)
        m_database->logEvent(QStringLiteral("Security"),
            QStringLiteral("User logged in: ") + username
                + QStringLiteral(" (") + m_currentRole + QStringLiteral(")"));

    return true;
}

void UserController::logout()
{
    if (m_currentUser.isEmpty())
        return;

    if (m_database)
        m_database->logEvent(QStringLiteral("Security"),
            QStringLiteral("User logged out: ") + m_currentUser);

    m_currentUser.clear();
    m_currentRole.clear();
    emit sessionChanged();
}

bool UserController::createUser(const QString &username,
                                 const QString &pin,
                                 const QString &role,
                                 const QString &fullName)
{
    if (!m_database || m_currentRole != QStringLiteral("Admin"))
        return false;

    if (username.length() < 3 || !pinFormatValid(pin) || !roleValid(role))
        return false;

    const QString salt = createSalt();

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "INSERT INTO users(username, pin_hash, salt, role, full_name, created_at) "
        "VALUES(?, ?, ?, ?, ?, ?)"));
    query.addBindValue(username);
    query.addBindValue(hashPin(pin, salt));
    query.addBindValue(salt);
    query.addBindValue(role);
    query.addBindValue(fullName);
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));

    if (!query.exec()) {
        qWarning() << "Failed to create user:" << query.lastError().text();
        return false;
    }

    if (m_database)
        m_database->logEvent(QStringLiteral("Security"),
            QStringLiteral("User created: ") + username
                + QStringLiteral(" role=") + role
                + QStringLiteral(" by ") + m_currentUser);

    emit userListChanged();
    return true;
}

bool UserController::deleteUser(const QString &username)
{
    if (!m_database || m_currentRole != QStringLiteral("Admin"))
        return false;

    // Prevent deleting yourself
    if (username == m_currentUser)
        return false;

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral("DELETE FROM users WHERE username = ?"));
    query.addBindValue(username);

    if (!query.exec() || query.numRowsAffected() == 0)
        return false;

    if (m_database)
        m_database->logEvent(QStringLiteral("Security"),
            QStringLiteral("User deleted: ") + username
                + QStringLiteral(" by ") + m_currentUser);

    emit userListChanged();
    return true;
}

bool UserController::changePin(const QString &username, const QString &newPin)
{
    if (!m_database)
        return false;

    // Only Admin can change other users' PINs; users can change their own
    if (username != m_currentUser
        && m_currentRole != QStringLiteral("Admin"))
        return false;

    if (!pinFormatValid(newPin))
        return false;

    const QString salt = createSalt();

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "UPDATE users SET pin_hash = ?, salt = ?, failed_attempts = 0, locked_until = '' WHERE username = ?"));
    query.addBindValue(hashPin(newPin, salt));
    query.addBindValue(salt);
    query.addBindValue(username);

    if (!query.exec() || query.numRowsAffected() == 0)
        return false;

    if (m_database)
        m_database->logEvent(QStringLiteral("Security"),
            QStringLiteral("PIN changed for user: ") + username
                + QStringLiteral(" by ") + m_currentUser);

    return true;
}

bool UserController::updateUser(const QString &username,
                                 const QString &role,
                                 const QString &fullName)
{
    if (!m_database || m_currentRole != QStringLiteral("Admin"))
        return false;

    if (!roleValid(role))
        return false;

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "UPDATE users SET role = ?, full_name = ? WHERE username = ?"));
    query.addBindValue(role);
    query.addBindValue(fullName);
    query.addBindValue(username);

    if (!query.exec() || query.numRowsAffected() == 0)
        return false;

    if (m_database)
        m_database->logEvent(QStringLiteral("Security"),
            QStringLiteral("User updated: ") + username
                + QStringLiteral(" role=") + role
                + QStringLiteral(" by ") + m_currentUser);

    emit userListChanged();
    return true;
}

QVariantList UserController::listUsers() const
{
    QVariantList result;
    if (!m_database)
        return result;

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));

    if (!query.exec(QStringLiteral(
            "SELECT username, role, full_name, created_at "
            "FROM users ORDER BY created_at ASC"))) {
        return result;
    }

    while (query.next()) {
        result.append(QVariantMap{
            { QStringLiteral("username"),  query.value(0).toString() },
            { QStringLiteral("role"),      query.value(1).toString() },
            { QStringLiteral("fullName"),  query.value(2).toString() },
            { QStringLiteral("createdAt"), query.value(3).toString() }
        });
    }
    return result;
}

bool UserController::hasAccess(const QString &requiredRole) const
{
    return roleLevel(m_currentRole) >= roleLevel(requiredRole);
}

void UserController::setLockTimeoutSeconds(int seconds)
{
    seconds = qBound(30, seconds, 3600);
    if (m_lockTimeoutSeconds == seconds)
        return;
    m_lockTimeoutSeconds = seconds;
    emit lockTimeoutChanged();
}

void UserController::persistFailedLogin(const QString &username, int failures, const QDateTime &lockedUntilUtc)
{
    QSqlQuery query(QSqlDatabase::database(QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "UPDATE users SET failed_attempts = ?, locked_until = ? WHERE username = ?"));
    query.addBindValue(failures);
    query.addBindValue(lockedUntilUtc.isValid() ? lockedUntilUtc.toString(Qt::ISODate) : QStringLiteral(""));
    query.addBindValue(username);
    if (!query.exec())
        qWarning() << "Failed to persist login lockout:" << query.lastError().text();
}

void UserController::clearFailedLogin(const QString &username)
{
    QSqlQuery query(QSqlDatabase::database(QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "UPDATE users SET failed_attempts = 0, locked_until = '' WHERE username = ?"));
    query.addBindValue(username);
    if (!query.exec())
        qWarning() << "Failed to clear login lockout:" << query.lastError().text();
}

void UserController::provisionInitialAdminFromEnvironment()
{
    if (!m_database)
        return;

    const QString bootstrapUser = qEnvironmentVariable("SMARTVENT_ADMIN_USER").trimmed();
    const QString bootstrapPin = qEnvironmentVariable("SMARTVENT_ADMIN_PIN");
    const bool bootstrapValid = !bootstrapUser.isEmpty() && pinFormatValid(bootstrapPin);

    QSqlQuery check(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    if (check.exec(QStringLiteral("SELECT COUNT(*) FROM users"))
        && check.next() && check.value(0).toInt() > 0) {
        if (!bootstrapValid)
            return;

        QSqlQuery legacy(QSqlDatabase::database(QStringLiteral("SmartVentilatorConnection")));
        legacy.prepare(QStringLiteral("SELECT salt FROM users WHERE username = ?"));
        legacy.addBindValue(bootstrapUser);
        if (!legacy.exec() || !legacy.next() || !legacy.value(0).toString().isEmpty())
            return;

        const QString salt = createSalt();
        QSqlQuery update(QSqlDatabase::database(QStringLiteral("SmartVentilatorConnection")));
        update.prepare(QStringLiteral(
            "UPDATE users SET pin_hash = :pin_hash, salt = :salt, role = 'Admin', "
            "full_name = :full_name, failed_attempts = 0, locked_until = '' "
            "WHERE username = :username"));
        update.bindValue(QStringLiteral(":pin_hash"), hashPin(bootstrapPin, salt));
        update.bindValue(QStringLiteral(":salt"), salt);
        update.bindValue(QStringLiteral(":full_name"), QStringLiteral("Bootstrap Administrator"));
        update.bindValue(QStringLiteral(":username"), bootstrapUser);
        if (!update.exec()) {
            qWarning() << "Failed to upgrade legacy bootstrap user:" << update.lastError().text();
            return;
        }

        m_database->logEvent(QStringLiteral("Security"),
                             QStringLiteral("Legacy bootstrap operator upgraded to salted credentials"),
                             QStringLiteral("Provisioned"));
        return;
    }

    if (!bootstrapValid) {
        m_database->logEvent(QStringLiteral("Security"),
                             QStringLiteral("No default demo credentials created; set SMARTVENT_ADMIN_USER and SMARTVENT_ADMIN_PIN to bootstrap an admin"),
                             QStringLiteral("ProvisioningRequired"));
        return;
    }

    // Temporarily elevate to Admin to create the single environment-provided bootstrap account.
    const QString savedUser = m_currentUser;
    const QString savedRole = m_currentRole;
    m_currentUser = QStringLiteral("system");
    m_currentRole = QStringLiteral("Admin");

    createUser(bootstrapUser, bootstrapPin,
               QStringLiteral("Admin"), QStringLiteral("Bootstrap Administrator"));

    m_currentUser = savedUser;
    m_currentRole = savedRole;
}
