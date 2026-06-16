#pragma once

#include <QAbstractListModel>
#include <QTimer>
#include <QVector>

class DatabaseManager;

/**
 * @brief QML list model and state controller for ventilator alarms.
 *
 * The model exposes rows with time, priority, source, description, and status
 * roles. It also exposes current alarm banner state through properties.
 */
class AlarmController : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY bannerChanged)
    Q_PROPERTY(QString priority READ priority WRITE setPriority NOTIFY bannerChanged)
    Q_PROPERTY(QString headline READ headline WRITE setHeadline NOTIFY bannerChanged)
    Q_PROPERTY(QString detail READ detail WRITE setDetail NOTIFY bannerChanged)
    Q_PROPERTY(bool silenced READ silenced NOTIFY silenceChanged)
    Q_PROPERTY(int silenceRemaining READ silenceRemaining NOTIFY silenceChanged)
    Q_PROPERTY(QString filterPriority READ filterPriority WRITE setFilterPriority NOTIFY filterChanged)
    Q_PROPERTY(bool audioActive READ audioActive NOTIFY audioChanged)
    Q_PROPERTY(int alarmCount READ alarmCount NOTIFY filterChanged)

public:
    enum AlarmRoles {
        TimeRole = Qt::UserRole + 1,
        PriorityRole,
        SourceRole,
        DescriptionRole,
        StatusRole
    };

    /**
     * @param database  Shared database manager for alarm persistence.
     * @param parent  Optional QObject parent for ownership.
     */
    explicit AlarmController(DatabaseManager *database, QObject *parent = nullptr);

    /** @return Number of alarm rows in the model. */
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    /** @return Data for the given alarm row and role. */
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    /** @return Mapping of AlarmRoles to QML role name strings. */
    QHash<int, QByteArray> roleNames() const override;

    bool active() const;
    QString priority() const;
    QString headline() const;
    QString detail() const;

    /** @brief Clears the active alarm banner and marks the top alarm as acknowledged. */
    Q_INVOKABLE void acknowledgeActiveAlarm();

    /**
     * @brief Activates alarm silence for the specified duration.
     * @param durationSeconds  Silence period in seconds (default 120, per IEC 60601-1-8).
     */
    Q_INVOKABLE void silenceAlarms(int durationSeconds = 120);

    /** @brief Cancels an active alarm silence period. */
    Q_INVOKABLE void cancelSilence();

    bool silenced() const;
    int silenceRemaining() const;

    /**
     * @brief Inserts a new alarm row into the model and persists it to the database.
     * @param priority  Alarm severity ("Critical", "Warning", or "Info").
     * @param source  Subsystem that raised the alarm (e.g. "Pressure").
     * @param description  Human-readable alarm detail.
     * @param status  Initial alarm state ("Active", "Acknowledged").
     */
    Q_INVOKABLE void addAlarm(const QString &priority,
                              const QString &source,
                              const QString &description,
                              const QString &status);

    /** @brief Raises or updates the current alarm banner and records history. */
    Q_INVOKABLE void raiseAlarm(const QString &priority,
                                const QString &source,
                                const QString &headline,
                                const QString &detail);

    /** @return True when alarm audio should be playing (active and not silenced). */
    bool audioActive() const;

    /** @return Total number of alarm rows (filtered). */
    int alarmCount() const;

    /** @return Current filter priority ("" for all, or "Critical"/"Warning"/"Info"). */
    QString filterPriority() const;

    /** @brief Sets the priority filter. Empty string shows all alarms. */
    Q_INVOKABLE void setFilterPriority(const QString &priority);

public slots:
    void setActive(bool value);
    void setPriority(const QString &value);
    void setHeadline(const QString &value);
    void setDetail(const QString &value);

signals:
    void bannerChanged();
    void silenceChanged();
    void filterChanged();
    void audioChanged();

private:
    struct AlarmRow {
        QString time;
        QString priority;
        QString source;
        QString description;
        QString status;
    };

    static int priorityWeight(const QString &priority);
    void rebuildFilteredIndices();

    QVector<AlarmRow> m_rows;
    QVector<int> m_filteredIndices;
    QString m_filterPriority;
    DatabaseManager *m_database = nullptr;
    bool m_active = false;
    QString m_priority = QStringLiteral("Normal");
    QString m_headline = QStringLiteral("No Active Alarms");
    QString m_detail = QStringLiteral("System normal");
    bool m_silenced = false;
    int m_silenceRemaining = 0;
    QTimer m_silenceTimer;
};
