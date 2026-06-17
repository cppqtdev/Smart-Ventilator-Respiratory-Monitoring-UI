#include "DatabaseManager.h"

#include <QDateTime>
#include <QDir>
#include <QMetaObject>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QVariant>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QStorageInfo>
#include <QTextStream>

namespace {
constexpr qint64 kMinimumFreeBytes = 10 * 1024 * 1024;

QString hashEventPayload(const QString &previousHash,
                         const QString &timestamp,
                         const QString &source,
                         const QString &description,
                         const QString &status)
{
    return QString::fromLatin1(QCryptographicHash::hash(
        (previousHash + timestamp + source + description + status).toUtf8(),
        QCryptographicHash::Sha256).toHex());
}

QString sqlString(const QString &value)
{
    QString escaped = value;
    escaped.replace(QLatin1Char('\''), QStringLiteral("''"));
    return QStringLiteral("'") + escaped + QStringLiteral("'");
}
}

class DatabaseWriteWorker : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseWriteWorker(QString databasePath)
        : m_databasePath(std::move(databasePath))
    {
    }

public slots:
    void open()
    {
        const QString connectionName = QStringLiteral("SmartVentilatorWriter_%1")
            .arg(reinterpret_cast<quintptr>(QThread::currentThreadId()));
        m_database = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), connectionName);
        m_database.setDatabaseName(m_databasePath);
        if (!m_database.open()) {
            emit writeFailed(QStringLiteral("Async database writer open failed: ")
                             + m_database.lastError().text());
        }
    }

    void close()
    {
        const QString connectionName = m_database.connectionName();
        if (m_database.isOpen())
            m_database.close();
        m_database = {};
        if (!connectionName.isEmpty())
            QSqlDatabase::removeDatabase(connectionName);
    }

    void logEvent(const QString &source, const QString &description, const QString &status)
    {
        if (!ensureOpen())
            return;

        const QString timestamp = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
        QString previousHash;
        QSqlQuery prev(m_database);
        if (prev.exec(QStringLiteral("SELECT hash FROM events ORDER BY id DESC LIMIT 1"))
            && prev.next()) {
            previousHash = prev.value(0).toString();
        }

        const QString hash = hashEventPayload(previousHash, timestamp, source, description, status);
        QSqlQuery query(m_database);
        if (!query.exec(QStringLiteral(
                "INSERT INTO events(created_at, source, description, status, hash) "
                "VALUES(%1, %2, %3, %4, %5)")
                .arg(sqlString(timestamp),
                     sqlString(source),
                     sqlString(description),
                     sqlString(status),
                     sqlString(hash)))) {
            qWarning() << "DatabaseManager:"
                       << QStringLiteral("Unable to insert event: ") + query.lastError().text();
        }
    }

    void logAlarm(const QString &priority,
                  const QString &source,
                  const QString &description,
                  const QString &status)
    {
        if (!ensureOpen())
            return;

        QSqlQuery query(m_database);
        query.prepare(QStringLiteral(
            "INSERT INTO alarms(created_at, priority, source, description, status) "
            "VALUES(?, ?, ?, ?, ?)"));
        query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
        query.addBindValue(priority);
        query.addBindValue(source);
        query.addBindValue(description);
        query.addBindValue(status);
        exec(query, QStringLiteral("Unable to insert alarm"));
    }

    void saveParameterSnapshot(const QVariantMap &snapshot)
    {
        if (!ensureOpen())
            return;

        QSqlQuery query(m_database);
        query.prepare(QStringLiteral(
            "INSERT INTO parameter_snapshots(created_at, mode, fio2, peep, pressure_support, "
            "respiratory_rate, minute_volume, tidal_volume, ppeak, pplat, pmean, spo2, etco2, "
            "compliance, resistance) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"));
        query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
        query.addBindValue(snapshot.value(QStringLiteral("mode")));
        query.addBindValue(snapshot.value(QStringLiteral("fio2")));
        query.addBindValue(snapshot.value(QStringLiteral("peep")));
        query.addBindValue(snapshot.value(QStringLiteral("pressureSupport")));
        query.addBindValue(snapshot.value(QStringLiteral("respiratoryRate")));
        query.addBindValue(snapshot.value(QStringLiteral("minuteVolume")));
        query.addBindValue(snapshot.value(QStringLiteral("tidalVolume")));
        query.addBindValue(snapshot.value(QStringLiteral("ppeak")));
        query.addBindValue(snapshot.value(QStringLiteral("pplat")));
        query.addBindValue(snapshot.value(QStringLiteral("pmean")));
        query.addBindValue(snapshot.value(QStringLiteral("spo2")));
        query.addBindValue(snapshot.value(QStringLiteral("etco2")));
        query.addBindValue(snapshot.value(QStringLiteral("compliance")));
        query.addBindValue(snapshot.value(QStringLiteral("resistance")));
        exec(query, QStringLiteral("Unable to insert snapshot"));
    }

    void savePatientProfile(const QVariantMap &profile)
    {
        if (!ensureOpen())
            return;

        QSqlQuery query(m_database);
        query.prepare(QStringLiteral(
            "INSERT INTO patient_profiles(created_at, category, gender, age, height, weight, ibw) "
            "VALUES(?, ?, ?, ?, ?, ?, ?)"));
        query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
        query.addBindValue(profile.value(QStringLiteral("category")));
        query.addBindValue(profile.value(QStringLiteral("gender")));
        query.addBindValue(profile.value(QStringLiteral("age")));
        query.addBindValue(profile.value(QStringLiteral("height")));
        query.addBindValue(profile.value(QStringLiteral("weight")));
        query.addBindValue(profile.value(QStringLiteral("ibw")));
        exec(query, QStringLiteral("Unable to save patient profile"));
    }

signals:
    void writeFailed(const QString &message);

private:
    bool ensureOpen()
    {
        if (m_database.isOpen())
            return true;
        open();
        return m_database.isOpen();
    }

    void exec(QSqlQuery &query, const QString &context)
    {
        if (!query.exec())
            emit writeFailed(context + QStringLiteral(": ") + query.lastError().text());
    }

    QString m_databasePath;
    QSqlDatabase m_database;
};

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    stopAsyncWriter();
    if (m_database.isOpen())
        m_database.close();
}

bool DatabaseManager::initialize()
{
    // PRODUCTION: For FDA 21 CFR Part 11 compliance, the database file must
    // be stored on an encrypted partition with access control. Consider using
    // SQLCipher for at-rest encryption of clinical records.

    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (dataDir.isEmpty() || !QDir().mkpath(dataDir)) {
        setStorageState(false, true, true, QStringLiteral("Application data directory unavailable"));
        setError(QStringLiteral("Unable to create application data directory"));
        return false;
    }
    m_databasePath = dataDir + QStringLiteral("/smart_ventilator_demo.sqlite");

    if (!checkStorageHealth())
        return false;

    const QString connectionName = QStringLiteral("SmartVentilatorConnection");
    if (QSqlDatabase::contains(connectionName))
        m_database = QSqlDatabase::database(connectionName);
    else
        m_database = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), connectionName);

    m_database.setDatabaseName(m_databasePath);
    if (!m_database.open()) {
        setStorageState(false, true, true, QStringLiteral("Database open failed"));
        setError(QStringLiteral("Unable to open database: ") + m_database.lastError().text());
        return false;
    }

    if (!executeSchema()) {
        setStorageState(false, false, true, QStringLiteral("Database schema failed"));
        return false;
    }

    setStorageState(true, false, false, QStringLiteral("Ready"));
    startAsyncWriter();
    return true;
}

QString DatabaseManager::databasePath() const
{
    return m_databasePath;
}

QString DatabaseManager::lastError() const
{
    return m_lastError;
}

bool DatabaseManager::ready() const { return m_ready; }
bool DatabaseManager::readOnly() const { return m_readOnly; }
bool DatabaseManager::degraded() const { return m_degraded; }
QString DatabaseManager::storageState() const { return m_storageState; }

void DatabaseManager::setError(const QString &message)
{
    m_lastError = message;
    qWarning() << "DatabaseManager:" << message;
    emit errorOccurred(message);
}

void DatabaseManager::setStorageState(bool ready, bool readOnly, bool degraded, const QString &state)
{
    const bool changed = m_ready != ready
        || m_readOnly != readOnly
        || m_degraded != degraded
        || m_storageState != state;
    m_ready = ready;
    m_readOnly = readOnly;
    m_degraded = degraded;
    m_storageState = state;
    if (changed)
        emit storageStateChanged();
}

bool DatabaseManager::checkStorageHealth()
{
    const QFileInfo info(m_databasePath);
    const QStorageInfo storage(info.absolutePath());
    if (!storage.isValid() || !storage.isReady()) {
        setStorageState(false, true, true, QStringLiteral("Storage not ready"));
        setError(QStringLiteral("Storage volume is not ready"));
        return false;
    }
    if (storage.bytesAvailable() >= 0 && storage.bytesAvailable() < kMinimumFreeBytes) {
        setStorageState(false, true, true, QStringLiteral("Storage full"));
        setError(QStringLiteral("Storage full: less than 10 MB available"));
        return false;
    }

    QFile probe(info.absolutePath() + QStringLiteral("/.smart_ventilator_write_test"));
    if (!probe.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        setStorageState(false, true, true, QStringLiteral("Read-only filesystem"));
        setError(QStringLiteral("Storage is read-only: ") + probe.errorString());
        return false;
    }
    probe.write("ok");
    probe.close();
    probe.remove();
    return true;
}

void DatabaseManager::startAsyncWriter()
{
    if (m_writer || m_databasePath.isEmpty())
        return;

    m_writer = new DatabaseWriteWorker(m_databasePath);
    m_writer->moveToThread(&m_writerThread);
    connect(&m_writerThread, &QThread::started, m_writer, &DatabaseWriteWorker::open);
    connect(&m_writerThread, &QThread::finished, m_writer, &QObject::deleteLater);
    connect(m_writer, &DatabaseWriteWorker::writeFailed, this, [this](const QString &message) {
        setStorageState(m_ready, m_readOnly, true, QStringLiteral("Async write failure"));
        setError(message);
    });
    m_writerThread.start();
}

void DatabaseManager::stopAsyncWriter()
{
    if (!m_writer)
        return;
    QMetaObject::invokeMethod(m_writer, "close", Qt::BlockingQueuedConnection);
    m_writerThread.quit();
    m_writerThread.wait();
    m_writer = nullptr;
}

bool DatabaseManager::executeSchema()
{
    static const char *schema[] = {
        "CREATE TABLE IF NOT EXISTS events ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "created_at TEXT NOT NULL,"
        "source TEXT NOT NULL,"
        "description TEXT NOT NULL,"
        "status TEXT NOT NULL,"
        "hash TEXT NOT NULL DEFAULT '')",
        "CREATE TABLE IF NOT EXISTS alarms ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "created_at TEXT NOT NULL,"
        "priority TEXT NOT NULL,"
        "source TEXT NOT NULL,"
        "description TEXT NOT NULL,"
        "status TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS patient_profiles ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "created_at TEXT NOT NULL,"
        "category TEXT NOT NULL,"
        "gender TEXT NOT NULL,"
        "age INTEGER NOT NULL,"
        "height INTEGER NOT NULL,"
        "weight INTEGER NOT NULL,"
        "ibw INTEGER NOT NULL)",
        "CREATE TABLE IF NOT EXISTS users ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "username TEXT NOT NULL UNIQUE,"
        "pin_hash TEXT NOT NULL,"
        "salt TEXT NOT NULL DEFAULT '',"
        "role TEXT NOT NULL,"
        "full_name TEXT NOT NULL,"
        "failed_attempts INTEGER NOT NULL DEFAULT 0,"
        "locked_until TEXT NOT NULL DEFAULT '',"
        "created_at TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS parameter_snapshots ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "created_at TEXT NOT NULL,"
        "mode TEXT NOT NULL,"
        "fio2 INTEGER NOT NULL,"
        "peep INTEGER NOT NULL,"
        "pressure_support INTEGER NOT NULL,"
        "respiratory_rate INTEGER NOT NULL,"
        "minute_volume INTEGER NOT NULL,"
        "tidal_volume INTEGER NOT NULL,"
        "ppeak REAL NOT NULL,"
        "pplat REAL NOT NULL,"
        "pmean REAL NOT NULL,"
        "spo2 REAL NOT NULL,"
        "etco2 REAL NOT NULL,"
        "compliance REAL NOT NULL,"
        "resistance REAL NOT NULL)",
        "CREATE TABLE IF NOT EXISTS clinical_state ("
        "key TEXT PRIMARY KEY,"
        "value TEXT NOT NULL,"
        "updated_at TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS sbt_sessions ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "created_at TEXT NOT NULL,"
        "status TEXT NOT NULL,"
        "rsbi REAL NOT NULL,"
        "spo2 REAL NOT NULL,"
        "fio2 REAL NOT NULL,"
        "peep REAL NOT NULL)",
        "CREATE TABLE IF NOT EXISTS maintenance_log ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "created_at TEXT NOT NULL,"
        "item TEXT NOT NULL,"
        "action TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS maneuver_results ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "created_at TEXT NOT NULL,"
        "type TEXT NOT NULL,"
        "result REAL NOT NULL,"
        "unit TEXT NOT NULL,"
        "notes TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS maintenance_schedules ("
        "item TEXT PRIMARY KEY,"
        "due_date TEXT NOT NULL,"
        "acknowledged INTEGER NOT NULL DEFAULT 0,"
        "updated_at TEXT NOT NULL)",
        "CREATE TABLE IF NOT EXISTS central_patients ("
        "bed TEXT PRIMARY KEY,"
        "patient_id TEXT NOT NULL,"
        "spo2 REAL NOT NULL,"
        "ppeak REAL NOT NULL,"
        "status TEXT NOT NULL,"
        "updated_at TEXT NOT NULL)"
    };

    for (const char *statement : schema) {
        QSqlQuery query(m_database);
        if (!query.exec(QString::fromUtf8(statement))) {
            setError(QStringLiteral("Schema error: ") + query.lastError().text());
            return false;
        }
    }

    struct ColumnPatch {
        const char *table;
        const char *column;
        const char *alterSql;
    };
    static const ColumnPatch patches[] = {
        { "events", "hash", "ALTER TABLE events ADD COLUMN hash TEXT NOT NULL DEFAULT ''" },
        { "users", "salt", "ALTER TABLE users ADD COLUMN salt TEXT NOT NULL DEFAULT ''" },
        { "users", "failed_attempts", "ALTER TABLE users ADD COLUMN failed_attempts INTEGER NOT NULL DEFAULT 0" },
        { "users", "locked_until", "ALTER TABLE users ADD COLUMN locked_until TEXT NOT NULL DEFAULT ''" }
    };

    for (const auto &patch : patches) {
        QSqlQuery columns(m_database);
        columns.exec(QStringLiteral("PRAGMA table_info(%1)").arg(QString::fromLatin1(patch.table)));
        bool exists = false;
        while (columns.next()) {
            if (columns.value(1).toString() == QString::fromLatin1(patch.column)) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            QSqlQuery alter(m_database);
            if (!alter.exec(QString::fromLatin1(patch.alterSql))) {
                setError(QStringLiteral("Schema migration error: ") + alter.lastError().text());
                return false;
            }
        }
    }

    return true;
}

void DatabaseManager::logEvent(const QString &source, const QString &description, const QString &status)
{
    if (!m_writer || !m_ready)
        return;
    QMetaObject::invokeMethod(m_writer, "logEvent", Qt::QueuedConnection,
                              Q_ARG(QString, source),
                              Q_ARG(QString, description),
                              Q_ARG(QString, status));
}

void DatabaseManager::logAlarm(const QString &priority,
                               const QString &source,
                               const QString &description,
                               const QString &status)
{
    if (!m_writer || !m_ready)
        return;
    QMetaObject::invokeMethod(m_writer, "logAlarm", Qt::QueuedConnection,
                              Q_ARG(QString, priority),
                              Q_ARG(QString, source),
                              Q_ARG(QString, description),
                              Q_ARG(QString, status));
}

void DatabaseManager::saveParameterSnapshot(const QVariantMap &snapshot)
{
    if (!m_writer || !m_ready)
        return;
    QMetaObject::invokeMethod(m_writer, "saveParameterSnapshot", Qt::QueuedConnection,
                              Q_ARG(QVariantMap, snapshot));
}

void DatabaseManager::savePatientProfile(const QVariantMap &profile)
{
    if (!m_writer || !m_ready)
        return;
    QMetaObject::invokeMethod(m_writer, "savePatientProfile", Qt::QueuedConnection,
                              Q_ARG(QVariantMap, profile));
}

QVariantMap DatabaseManager::loadLastPatientProfile()
{
    if (!m_database.isOpen())
        return {};

    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral(
            "SELECT category, gender, age, height, weight FROM patient_profiles "
            "ORDER BY id DESC LIMIT 1"))) {
        setError(QStringLiteral("Unable to load patient profile: ") + query.lastError().text());
        return {};
    }

    if (!query.next())
        return {};

    return {
        { QStringLiteral("category"), query.value(0).toString() },
        { QStringLiteral("gender"),   query.value(1).toString() },
        { QStringLiteral("age"),      query.value(2).toInt() },
        { QStringLiteral("height"),   query.value(3).toInt() },
        { QStringLiteral("weight"),   query.value(4).toInt() }
    };
}

bool DatabaseManager::verifyAuditTrail()
{
    if (!m_database.isOpen())
        return false;

    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral(
            "SELECT created_at, source, description, status, hash "
            "FROM events ORDER BY id ASC"))) {
        setError(QStringLiteral("Audit verification failed: ") + query.lastError().text());
        return false;
    }

    QString previousHash;
    int row = 0;
    while (query.next()) {
        ++row;
        const QString timestamp   = query.value(0).toString();
        const QString source      = query.value(1).toString();
        const QString description = query.value(2).toString();
        const QString status      = query.value(3).toString();
        const QString storedHash  = query.value(4).toString();

        // Skip legacy records that predate hash chain (empty hash field).
        if (storedHash.isEmpty()) {
            previousHash.clear();
            continue;
        }

        if (hashEventPayload(previousHash, timestamp, source, description, status) != storedHash) {
            setError(QStringLiteral("Audit trail integrity failure at event row %1").arg(row));
            return false;
        }

        previousHash = storedHash;
    }

    return true;
}

QVariantList DatabaseManager::getParameterHistory(int minutes) const
{
    QVariantList result;
    if (!m_database.isOpen())
        return result;

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "SELECT created_at, ppeak, pplat, pmean, spo2, etco2, "
        "fio2, peep, minute_volume, tidal_volume, respiratory_rate, "
        "compliance, resistance "
        "FROM parameter_snapshots "
        "WHERE datetime(created_at) >= datetime('now', ?) "
        "ORDER BY id ASC"));
    query.addBindValue(QStringLiteral("-%1 minutes").arg(qBound(1, minutes, 1440)));

    if (!query.exec())
        return result;

    while (query.next()) {
        result.append(QVariantMap{
            { QStringLiteral("time"),      query.value(0).toString() },
            { QStringLiteral("ppeak"),     query.value(1).toDouble() },
            { QStringLiteral("pplat"),     query.value(2).toDouble() },
            { QStringLiteral("pmean"),     query.value(3).toDouble() },
            { QStringLiteral("spo2"),      query.value(4).toDouble() },
            { QStringLiteral("etco2"),     query.value(5).toDouble() },
            { QStringLiteral("fio2"),      query.value(6).toInt() },
            { QStringLiteral("peep"),      query.value(7).toInt() },
            { QStringLiteral("mv"),        query.value(8).toInt() },
            { QStringLiteral("vt"),        query.value(9).toInt() },
            { QStringLiteral("rr"),        query.value(10).toInt() },
            { QStringLiteral("compliance"),query.value(11).toDouble() },
            { QStringLiteral("resistance"),query.value(12).toDouble() }
        });
    }
    return result;
}

QString DatabaseManager::exportClinicalSummary() const
{
    if (!m_database.isOpen())
        return {};

    const QString path = QFileInfo(m_databasePath).absolutePath()
        + QStringLiteral("/clinical_export_%1.csv")
              .arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_HHmmss")));
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return {};

    QTextStream out(&file);
    out << "timestamp,mode,ppeak,spo2,etco2,fio2,peep,tidal_volume,respiratory_rate\n";
    QSqlQuery query(m_database);
    if (query.exec(QStringLiteral(
            "SELECT created_at,mode,ppeak,spo2,etco2,fio2,peep,tidal_volume,"
            "respiratory_rate FROM parameter_snapshots ORDER BY id DESC LIMIT 500"))) {
        while (query.next()) {
            for (int i = 0; i < 9; ++i) {
                if (i) out << ',';
                QString value = query.value(i).toString();
                value.replace('"', QStringLiteral("\"\""));
                out << '"' << value << '"';
            }
            out << '\n';
        }
    }
    return path;
}

void DatabaseManager::saveClinicalState(const QString &key, const QVariant &value)
{
    if (!m_database.isOpen() || key.trimmed().isEmpty())
        return;

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO clinical_state(key,value,updated_at) VALUES(?,?,?) "
        "ON CONFLICT(key) DO UPDATE SET value=excluded.value,"
        "updated_at=excluded.updated_at"));
    query.addBindValue(key);
    query.addBindValue(value.toString());
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    if (!query.exec())
        setError(QStringLiteral("Unable to save clinical state: ") + query.lastError().text());
}

QVariantMap DatabaseManager::loadClinicalState() const
{
    QVariantMap result;
    if (!m_database.isOpen())
        return result;

    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral("SELECT key,value FROM clinical_state")))
        return result;
    while (query.next())
        result.insert(query.value(0).toString(), query.value(1));
    return result;
}

void DatabaseManager::recordSbtSession(const QVariantMap &session)
{
    if (!m_database.isOpen())
        return;

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO sbt_sessions(created_at,status,rsbi,spo2,fio2,peep) "
        "VALUES(?,?,?,?,?,?)"));
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    query.addBindValue(session.value(QStringLiteral("status")));
    query.addBindValue(session.value(QStringLiteral("rsbi")));
    query.addBindValue(session.value(QStringLiteral("spo2")));
    query.addBindValue(session.value(QStringLiteral("fio2")));
    query.addBindValue(session.value(QStringLiteral("peep")));
    if (!query.exec())
        setError(QStringLiteral("Unable to record SBT session: ") + query.lastError().text());
}

void DatabaseManager::recordMaintenance(const QString &item, const QString &action)
{
    if (!m_database.isOpen())
        return;

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO maintenance_log(created_at,item,action) VALUES(?,?,?)"));
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    query.addBindValue(item);
    query.addBindValue(action);
    if (!query.exec())
        setError(QStringLiteral("Unable to record maintenance: ") + query.lastError().text());
}

QVariantList DatabaseManager::getSbtHistory(int limit) const
{
    QVariantList result;
    if (!m_database.isOpen())
        return result;

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "SELECT created_at,status,rsbi,spo2,fio2,peep "
        "FROM sbt_sessions ORDER BY id DESC LIMIT ?"));
    query.addBindValue(qBound(1, limit, 200));
    if (!query.exec())
        return result;

    while (query.next()) {
        result.append(QVariantMap{
            { QStringLiteral("time"), query.value(0).toString() },
            { QStringLiteral("status"), query.value(1).toString() },
            { QStringLiteral("rsbi"), query.value(2).toDouble() },
            { QStringLiteral("spo2"), query.value(3).toDouble() },
            { QStringLiteral("fio2"), query.value(4).toDouble() },
            { QStringLiteral("peep"), query.value(5).toDouble() }
        });
    }
    return result;
}

QVariantList DatabaseManager::getMaintenanceHistory(int limit) const
{
    QVariantList result;
    if (!m_database.isOpen())
        return result;

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "SELECT created_at,item,action FROM maintenance_log "
        "ORDER BY id DESC LIMIT ?"));
    query.addBindValue(qBound(1, limit, 200));
    if (!query.exec())
        return result;

    while (query.next()) {
        result.append(QVariantMap{
            { QStringLiteral("time"), query.value(0).toString() },
            { QStringLiteral("item"), query.value(1).toString() },
            { QStringLiteral("action"), query.value(2).toString() }
        });
    }
    return result;
}

void DatabaseManager::recordManeuver(const QString &type, double result,
                                     const QString &unit, const QString &notes)
{
    if (!m_database.isOpen())
        return;
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO maneuver_results(created_at,type,result,unit,notes) "
        "VALUES(?,?,?,?,?)"));
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    query.addBindValue(type);
    query.addBindValue(result);
    query.addBindValue(unit);
    query.addBindValue(notes);
    if (!query.exec())
        setError(QStringLiteral("Unable to record maneuver: ") + query.lastError().text());
}

QVariantList DatabaseManager::getManeuverHistory(int limit) const
{
    QVariantList result;
    if (!m_database.isOpen())
        return result;
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "SELECT created_at,type,result,unit,notes FROM maneuver_results "
        "ORDER BY id DESC LIMIT ?"));
    query.addBindValue(qBound(1, limit, 200));
    if (!query.exec())
        return result;
    while (query.next()) {
        result.append(QVariantMap{
            { QStringLiteral("time"), query.value(0).toString() },
            { QStringLiteral("type"), query.value(1).toString() },
            { QStringLiteral("result"), query.value(2).toDouble() },
            { QStringLiteral("unit"), query.value(3).toString() },
            { QStringLiteral("notes"), query.value(4).toString() }
        });
    }
    return result;
}

void DatabaseManager::saveMaintenanceSchedule(const QString &item,
                                              const QString &dueDate,
                                              bool acknowledged)
{
    if (!m_database.isOpen() || item.trimmed().isEmpty())
        return;
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO maintenance_schedules(item,due_date,acknowledged,updated_at) "
        "VALUES(?,?,?,?) ON CONFLICT(item) DO UPDATE SET "
        "due_date=excluded.due_date,acknowledged=excluded.acknowledged,"
        "updated_at=excluded.updated_at"));
    query.addBindValue(item);
    query.addBindValue(dueDate);
    query.addBindValue(acknowledged ? 1 : 0);
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    if (!query.exec())
        setError(QStringLiteral("Unable to save maintenance schedule: ") + query.lastError().text());
}

QVariantList DatabaseManager::getMaintenanceSchedules() const
{
    QVariantList result;
    if (!m_database.isOpen())
        return result;
    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral(
            "SELECT item,due_date,acknowledged FROM maintenance_schedules "
            "ORDER BY due_date ASC")))
        return result;
    while (query.next()) {
        result.append(QVariantMap{
            { QStringLiteral("item"), query.value(0).toString() },
            { QStringLiteral("dueDate"), query.value(1).toString() },
            { QStringLiteral("acknowledged"), query.value(2).toBool() }
        });
    }
    return result;
}

void DatabaseManager::saveCentralPatient(const QVariantMap &patient)
{
    if (!m_database.isOpen())
        return;
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO central_patients(bed,patient_id,spo2,ppeak,status,updated_at) "
        "VALUES(?,?,?,?,?,?) ON CONFLICT(bed) DO UPDATE SET "
        "patient_id=excluded.patient_id,spo2=excluded.spo2,ppeak=excluded.ppeak,"
        "status=excluded.status,updated_at=excluded.updated_at"));
    query.addBindValue(patient.value(QStringLiteral("bed")));
    query.addBindValue(patient.value(QStringLiteral("patientId")));
    query.addBindValue(patient.value(QStringLiteral("spo2")));
    query.addBindValue(patient.value(QStringLiteral("ppeak")));
    query.addBindValue(patient.value(QStringLiteral("status")));
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    if (!query.exec())
        setError(QStringLiteral("Unable to save central patient: ") + query.lastError().text());
}

QVariantList DatabaseManager::getCentralPatients() const
{
    QVariantList result;
    if (!m_database.isOpen())
        return result;
    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral(
            "SELECT bed,patient_id,spo2,ppeak,status FROM central_patients "
            "ORDER BY bed ASC")))
        return result;
    while (query.next()) {
        result.append(QVariantMap{
            { QStringLiteral("bed"), query.value(0).toString() },
            { QStringLiteral("patientId"), query.value(1).toString() },
            { QStringLiteral("spo2"), query.value(2).toDouble() },
            { QStringLiteral("ppeak"), query.value(3).toDouble() },
            { QStringLiteral("status"), query.value(4).toString() }
        });
    }
    return result;
}

QString DatabaseManager::exportAuditSummary() const
{
    if (!m_database.isOpen())
        return {};
    const QString path = QFileInfo(m_databasePath).absolutePath()
        + QStringLiteral("/audit_export_%1.csv")
              .arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_HHmmss")));
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return {};
    QTextStream out(&file);
    out << "timestamp,type,source,description,status\n";
    QSqlQuery query(m_database);
    if (query.exec(QStringLiteral(
            "SELECT created_at,'Event',source,description,status FROM events "
            "UNION ALL SELECT created_at,'Alarm',source,description,status FROM alarms "
            "ORDER BY created_at DESC LIMIT 1000"))) {
        while (query.next()) {
            for (int i = 0; i < 5; ++i) {
                if (i) out << ',';
                QString value = query.value(i).toString();
                value.replace('"', QStringLiteral("\"\""));
                out << '"' << value << '"';
            }
            out << '\n';
        }
    }
    return path;
}

#include "DatabaseManager.moc"
