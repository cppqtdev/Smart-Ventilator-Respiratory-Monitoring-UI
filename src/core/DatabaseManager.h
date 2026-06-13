#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QString>
#include <QVariantMap>

/**
 * @brief Owns the application SQLite database connection and schema lifecycle.
 *
 * DatabaseManager creates a local SQLite database in the platform application
 * data directory. It stores clinical-demo audit events, alarm history, patient
 * profiles, and periodic ventilator parameter snapshots. The class is designed
 * as an infrastructure boundary so a production hardware build can replace or
 * extend persistence without touching QML screens.
 */
class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager() override;

    /**
     * @brief Opens the SQLite database and creates missing tables.
     * @return true when the database is ready for use.
     */
    bool initialize();

    /**
     * @brief Records a user/system event in the audit log.
     */
    Q_INVOKABLE void logEvent(const QString &source,
                              const QString &description,
                              const QString &status = QStringLiteral("Recorded"));

    /**
     * @brief Records an alarm transition in the alarm history table.
     */
    Q_INVOKABLE void logAlarm(const QString &priority,
                              const QString &source,
                              const QString &description,
                              const QString &status);

    /**
     * @brief Stores a ventilator parameter snapshot for demo trend/history use.
     */
    void saveParameterSnapshot(const QVariantMap &snapshot);

    /**
     * @brief Returns the absolute SQLite database path.
     */
    Q_INVOKABLE QString databasePath() const;

private:
    bool executeSchema();
    QString m_databasePath;
    QSqlDatabase m_database;
};
