#include "EventController.h"
#include "../core/DatabaseManager.h"

#include <QDateTime>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

EventController::EventController(DatabaseManager *database, QObject *parent)
    : QAbstractListModel(parent)
    , m_database(database)
{
    loadFromDatabase();
}

int EventController::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_rows.size();
}

QVariant EventController::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_rows.size())
        return {};

    const EventRow &row = m_rows.at(index.row());

    switch (role) {
    case TimeRole:        return row.time;
    case SourceRole:      return row.source;
    case DescriptionRole: return row.description;
    case SeverityRole:    return row.severity;
    default:              return {};
    }
}

QHash<int, QByteArray> EventController::roleNames() const
{
    return {
        { TimeRole,        "time" },
        { SourceRole,      "source" },
        { DescriptionRole, "description" },
        { SeverityRole,    "severity" }
    };
}

void EventController::addEvent(const QString &source,
                                const QString &description,
                                const QString &severity)
{
    if (m_database) {
        m_database->logEvent(source, description, severity);
    }

    const QString timestamp = QDateTime::currentDateTime().toString(
        QStringLiteral("HH:mm:ss"));

    beginInsertRows(QModelIndex(), 0, 0);
    m_rows.prepend({ timestamp, source, description, severity });
    endInsertRows();
}

void EventController::refresh()
{
    beginResetModel();
    m_rows.clear();
    loadFromDatabase();
    endResetModel();
}

void EventController::loadFromDatabase()
{
    if (!m_database)
        return;

    QSqlQuery query(QSqlDatabase::database(
        QStringLiteral("SmartVentilatorConnection")));

    if (!query.exec(QStringLiteral(
            "SELECT created_at, source, description, status "
            "FROM events ORDER BY id DESC LIMIT 200"))) {
        qWarning() << "Unable to load events:" << query.lastError().text();
        return;
    }

    while (query.next()) {
        const QDateTime dt = QDateTime::fromString(
            query.value(0).toString(), Qt::ISODate);
        const QString timeStr = dt.isValid()
            ? dt.toLocalTime().toString(QStringLiteral("HH:mm:ss"))
            : query.value(0).toString();

        m_rows.append({
            timeStr,
            query.value(1).toString(),
            query.value(2).toString(),
            query.value(3).toString()
        });
    }
}
