#include "UserController.h"
#include "../core/DatabaseManager.h"

#include <QCryptographicHash>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

UserController::UserController(DatabaseManager *database, QObject *parent)
    : QObject(parent)
    , m_database(database)
{
    createDefaultUsers();
}

QString UserController::currentUser() const { return m_currentUser; }
QString UserController::currentRole() const { return m_currentRole; }
bool UserController::loggedIn() const { return !m_currentUser.isEmpty(); }
int UserController::lockTimeoutSeconds() const { return m_lockTimeoutSeconds; }

QString UserController::hashPin(const QString &pin)
{
    return QString::fromLatin1(
        QCryptographicHash::hash(pin.toUtf8(), QCryptographicHash::Sha256).toHex());
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

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "SELECT role, full_name FROM users WHERE username = ? AND pin_hash = ?"));
    query.addBindValue(username);
    query.addBindValue(hashPin(pin));

    if (!query.exec() || !query.next()) {
        emit loginFailed(QStringLiteral("Invalid username or PIN"));
        if (m_database)
            m_database->logEvent(QStringLiteral("Security"),
                QStringLiteral("Failed login attempt for user: ") + username);
        return false;
    }

    m_currentUser = username;
    m_currentRole = query.value(0).toString();
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

    if (username.length() < 3 || pin.length() != 4)
        return false;

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "INSERT INTO users(username, pin_hash, role, full_name, created_at) "
        "VALUES(?, ?, ?, ?, ?)"));
    query.addBindValue(username);
    query.addBindValue(hashPin(pin));
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

    if (newPin.length() != 4)
        return false;

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    query.prepare(QStringLiteral(
        "UPDATE users SET pin_hash = ? WHERE username = ?"));
    query.addBindValue(hashPin(newPin));
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

void UserController::createDefaultUsers()
{
    if (!m_database)
        return;

    QSqlQuery check(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));
    if (check.exec(QStringLiteral("SELECT COUNT(*) FROM users"))
        && check.next() && check.value(0).toInt() > 0) {
        return; // Users already exist
    }

    // Temporarily elevate to Admin to create default accounts
    const QString savedUser = m_currentUser;
    const QString savedRole = m_currentRole;
    m_currentUser = QStringLiteral("system");
    m_currentRole = QStringLiteral("Admin");

    createUser(QStringLiteral("admin"),   QStringLiteral("0000"),
               QStringLiteral("Admin"),   QStringLiteral("System Administrator"));
    createUser(QStringLiteral("doctor"),  QStringLiteral("1234"),
               QStringLiteral("Doctor"),  QStringLiteral("Dr. Default"));
    createUser(QStringLiteral("nurse"),   QStringLiteral("5678"),
               QStringLiteral("Nurse"),   QStringLiteral("Nurse Default"));
    createUser(QStringLiteral("service"), QStringLiteral("9999"),
               QStringLiteral("Service"), QStringLiteral("Service Technician"));

    m_currentUser = savedUser;
    m_currentRole = savedRole;
}
