#pragma once

#include <QAbstractListModel>
#include <QVector>

class DatabaseManager;

/**
 * @brief QML list model for the clinical event timeline.
 *
 * EventController reads event records from the SQLite database and exposes
 * them as a QAbstractListModel for the EventsScreen. New events are inserted
 * through the addEvent method and immediately appear in the model.
 */
class EventController : public QAbstractListModel
{
    Q_OBJECT

public:
    enum EventRoles {
        TimeRole = Qt::UserRole + 1,
        SourceRole,
        DescriptionRole,
        SeverityRole
    };

    /**
     * @param database  Shared database manager for event persistence.
     * @param parent  Optional QObject parent for ownership.
     */
    explicit EventController(DatabaseManager *database, QObject *parent = nullptr);

    /** @return Number of event rows in the model. */
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /** @return Data for the given event row and role. */
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /** @return Mapping of EventRoles to QML role name strings. */
    QHash<int, QByteArray> roleNames() const override;

    /**
     * @brief Inserts a new event at the top of the model and persists it to the database.
     * @param source  Subsystem that generated the event (e.g. "Mode", "Parameter", "Alarm").
     * @param description  Human-readable event detail.
     * @param severity  Visual severity hint ("normal", "warning", "critical").
     */
    Q_INVOKABLE void addEvent(const QString &source,
                               const QString &description,
                               const QString &severity = QStringLiteral("normal"));

    /** @brief Reloads all events from the database into the model. */
    Q_INVOKABLE void refresh();

private:
    void loadFromDatabase();

    struct EventRow {
        QString time;
        QString source;
        QString description;
        QString severity;
    };

    QVector<EventRow> m_rows;
    DatabaseManager *m_database = nullptr;
};
