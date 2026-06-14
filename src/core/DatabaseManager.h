#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QString>
#include <QVariantMap>
#include <QCryptographicHash>

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
    Q_PROPERTY(QString lastError READ lastError NOTIFY errorOccurred)

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
     * @param source  Subsystem that generated the event (e.g. "Mode", "Parameter").
     * @param description  Human-readable event detail.
     * @param status  Recording status label (default "Recorded").
     */
    Q_INVOKABLE void logEvent(const QString &source,
                              const QString &description,
                              const QString &status = QStringLiteral("Recorded"));

    /**
     * @brief Records an alarm transition in the alarm history table.
     * @param priority  Alarm severity ("Critical", "Warning", or "Info").
     * @param source  Subsystem that raised the alarm.
     * @param description  Human-readable alarm detail.
     * @param status  Current alarm state ("Active", "Acknowledged", "Resolved").
     */
    Q_INVOKABLE void logAlarm(const QString &priority,
                              const QString &source,
                              const QString &description,
                              const QString &status);

    /**
     * @brief Stores a ventilator parameter snapshot for demo trend/history use.
     * @param snapshot  Key-value map of parameter names to current values.
     */
    void saveParameterSnapshot(const QVariantMap &snapshot);

    /**
     * @brief Saves or updates a patient profile in the database.
     * @param profile  Key-value map with category, gender, age, height, weight, ibw.
     */
    void savePatientProfile(const QVariantMap &profile);

    /**
     * @brief Loads the most recent patient profile from the database.
     * @return Key-value map with patient fields, or empty map if none exists.
     */
    QVariantMap loadLastPatientProfile();

    /**
     * @brief Returns the absolute SQLite database path.
     */
    Q_INVOKABLE QString databasePath() const;

    /** @return Most recent database error message, empty if no error. */
    QString lastError() const;

    /**
     * @brief Verifies the SHA-256 hash chain integrity of the events table.
     * @return true if all event hashes are valid and unbroken.
     */
    Q_INVOKABLE bool verifyAuditTrail();

signals:
    /** @brief Emitted when a database write operation fails. */
    void errorOccurred(const QString &message);

private:
    void setError(const QString &message);
    bool executeSchema();
    QString m_databasePath;
    QString m_lastError;
    QSqlDatabase m_database;
};
