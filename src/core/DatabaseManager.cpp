#include "DatabaseManager.h"

#include <QDateTime>
#include <QDir>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QVariant>
#include <QDebug>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_database.isOpen())
        m_database.close();
}

bool DatabaseManager::initialize()
{
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);
    m_databasePath = dataDir + QStringLiteral("/smart_ventilator_demo.sqlite");

    const QString connectionName = QStringLiteral("SmartVentilatorConnection");
    if (QSqlDatabase::contains(connectionName))
        m_database = QSqlDatabase::database(connectionName);
    else
        m_database = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), connectionName);

    m_database.setDatabaseName(m_databasePath);
    if (!m_database.open()) {
        setError(QStringLiteral("Unable to open database: ") + m_database.lastError().text());
        return false;
    }

    return executeSchema();
}

QString DatabaseManager::databasePath() const
{
    return m_databasePath;
}

QString DatabaseManager::lastError() const
{
    return m_lastError;
}

void DatabaseManager::setError(const QString &message)
{
    m_lastError = message;
    qWarning() << "DatabaseManager:" << message;
    emit errorOccurred(message);
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
        "resistance REAL NOT NULL)"
    };

    for (const char *statement : schema) {
        QSqlQuery query(m_database);
        if (!query.exec(QString::fromUtf8(statement))) {
            setError(QStringLiteral("Schema error: ") + query.lastError().text());
            return false;
        }
    }

    return true;
}

void DatabaseManager::logEvent(const QString &source, const QString &description, const QString &status)
{
    if (!m_database.isOpen())
        return;

    const QString timestamp = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);

    // Retrieve the hash of the previous event for chain integrity.
    QString previousHash;
    {
        QSqlQuery prev(m_database);
        if (prev.exec(QStringLiteral("SELECT hash FROM events ORDER BY id DESC LIMIT 1"))
            && prev.next()) {
            previousHash = prev.value(0).toString();
        }
    }

    // Compute SHA-256 hash: H(previousHash + timestamp + source + description + status)
    const QString payload = previousHash + timestamp + source + description + status;
    const QByteArray hash = QCryptographicHash::hash(
        payload.toUtf8(), QCryptographicHash::Sha256).toHex();

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO events(created_at, source, description, status, hash) "
        "VALUES(?, ?, ?, ?, ?)"));
    query.addBindValue(timestamp);
    query.addBindValue(source);
    query.addBindValue(description);
    query.addBindValue(status);
    query.addBindValue(QString::fromLatin1(hash));
    if (!query.exec())
        setError(QStringLiteral("Unable to insert event: ") + query.lastError().text());
}

void DatabaseManager::logAlarm(const QString &priority,
                               const QString &source,
                               const QString &description,
                               const QString &status)
{
    if (!m_database.isOpen())
        return;

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO alarms(created_at, priority, source, description, status) VALUES(?, ?, ?, ?, ?)"));
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    query.addBindValue(priority);
    query.addBindValue(source);
    query.addBindValue(description);
    query.addBindValue(status);
    if (!query.exec())
        setError(QStringLiteral("Unable to insert alarm: ") + query.lastError().text());
}

void DatabaseManager::saveParameterSnapshot(const QVariantMap &snapshot)
{
    if (!m_database.isOpen())
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
    if (!query.exec())
        setError(QStringLiteral("Unable to insert snapshot: ") + query.lastError().text());
}

void DatabaseManager::savePatientProfile(const QVariantMap &profile)
{
    if (!m_database.isOpen())
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
    if (!query.exec())
        setError(QStringLiteral("Unable to save patient profile: ") + query.lastError().text());
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

        const QString payload = previousHash + timestamp + source + description + status;
        const QByteArray expected = QCryptographicHash::hash(
            payload.toUtf8(), QCryptographicHash::Sha256).toHex();

        if (QString::fromLatin1(expected) != storedHash) {
            setError(QStringLiteral("Audit trail integrity failure at event row %1").arg(row));
            return false;
        }

        previousHash = storedHash;
    }

    return true;
}
