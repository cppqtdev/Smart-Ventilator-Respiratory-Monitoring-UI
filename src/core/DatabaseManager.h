#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QString>
#include <QThread>
#include <QVariantMap>
#include <QCryptographicHash>

class DatabaseWriteWorker;

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
    Q_PROPERTY(bool ready READ ready NOTIFY storageStateChanged)
    Q_PROPERTY(bool readOnly READ readOnly NOTIFY storageStateChanged)
    Q_PROPERTY(bool degraded READ degraded NOTIFY storageStateChanged)
    Q_PROPERTY(QString storageState READ storageState NOTIFY storageStateChanged)

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
    bool ready() const;
    bool readOnly() const;
    bool degraded() const;
    QString storageState() const;

    /**
     * @brief Verifies the SHA-256 hash chain integrity of the events table.
     * @return true if all event hashes are valid and unbroken.
     */
    Q_INVOKABLE bool verifyAuditTrail();

    /**
     * @brief Queries parameter snapshots from the last N minutes.
     * @param minutes  Time window in minutes (e.g. 60, 360, 720, 1440).
     * @return List of snapshot maps with timestamp and all parameter values.
     */
    Q_INVOKABLE QVariantList getParameterHistory(int minutes) const;
    Q_INVOKABLE QString exportClinicalSummary() const;
    Q_INVOKABLE void saveClinicalState(const QString &key, const QVariant &value);
    Q_INVOKABLE QVariantMap loadClinicalState() const;
    Q_INVOKABLE void recordSbtSession(const QVariantMap &session);
    Q_INVOKABLE void recordMaintenance(const QString &item, const QString &action);
    Q_INVOKABLE QVariantList getSbtHistory(int limit = 20) const;
    Q_INVOKABLE QVariantList getMaintenanceHistory(int limit = 20) const;
    Q_INVOKABLE void recordManeuver(const QString &type, double result,
                                    const QString &unit, const QString &notes);
    Q_INVOKABLE QVariantList getManeuverHistory(int limit = 20) const;
    Q_INVOKABLE void saveMaintenanceSchedule(const QString &item,
                                             const QString &dueDate,
                                             bool acknowledged);
    Q_INVOKABLE QVariantList getMaintenanceSchedules() const;
    Q_INVOKABLE void saveCentralPatient(const QVariantMap &patient);
    Q_INVOKABLE QVariantList getCentralPatients() const;
    Q_INVOKABLE QString exportAuditSummary() const;

signals:
    /** @brief Emitted when a database write operation fails. */
    void errorOccurred(const QString &message);
    void storageStateChanged();

private:
    void setError(const QString &message);
    void setStorageState(bool ready, bool readOnly, bool degraded, const QString &state);
    bool executeSchema();
    bool checkStorageHealth();
    void startAsyncWriter();
    void stopAsyncWriter();
    QString m_databasePath;
    QString m_lastError;
    QString m_storageState = QStringLiteral("Not initialized");
    QSqlDatabase m_database;
    QThread m_writerThread;
    DatabaseWriteWorker *m_writer = nullptr;
    bool m_ready = false;
    bool m_readOnly = false;
    bool m_degraded = true;
};
