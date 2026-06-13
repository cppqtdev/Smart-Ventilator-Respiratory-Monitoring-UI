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
        qWarning() << "Unable to open SQLite database:" << m_database.lastError().text();
        return false;
    }

    return executeSchema();
}

QString DatabaseManager::databasePath() const
{
    return m_databasePath;
}

bool DatabaseManager::executeSchema()
{
    static const char *schema[] = {
        "CREATE TABLE IF NOT EXISTS events ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "created_at TEXT NOT NULL,"
        "source TEXT NOT NULL,"
        "description TEXT NOT NULL,"
        "status TEXT NOT NULL)",
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
            qWarning() << "SQLite schema error:" << query.lastError().text();
            return false;
        }
    }

    return true;
}

void DatabaseManager::logEvent(const QString &source, const QString &description, const QString &status)
{
    if (!m_database.isOpen())
        return;

    QSqlQuery query(m_database);
    query.prepare(QStringLiteral(
        "INSERT INTO events(created_at, source, description, status) VALUES(?, ?, ?, ?)"));
    query.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    query.addBindValue(source);
    query.addBindValue(description);
    query.addBindValue(status);
    if (!query.exec())
        qWarning() << "Unable to insert event:" << query.lastError().text();
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
        qWarning() << "Unable to insert alarm:" << query.lastError().text();
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
        qWarning() << "Unable to insert parameter snapshot:" << query.lastError().text();
}
