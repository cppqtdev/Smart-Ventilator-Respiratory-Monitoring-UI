#include "AlarmController.h"

#include "src/core/DatabaseManager.h"

#include <QDateTime>

AlarmController::AlarmController(DatabaseManager *database, QObject *parent)
    : QAbstractListModel(parent)
    , m_database(database)
{
    m_silenceTimer.setInterval(1000);
    connect(&m_silenceTimer, &QTimer::timeout, this, [this]() {
        --m_silenceRemaining;
        if (m_silenceRemaining <= 0) {
            m_silenced = false;
            m_silenceRemaining = 0;
            m_silenceTimer.stop();
        }
        emit silenceChanged();
    });

    addAlarm(QStringLiteral("Info"), QStringLiteral("System"),
             QStringLiteral("Controller initialized"), QStringLiteral("Closed"));
    rebuildFilteredIndices();
}

int AlarmController::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_filteredIndices.size();
}

QVariant AlarmController::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_filteredIndices.size())
        return {};

    const AlarmRow &row = m_rows.at(m_filteredIndices.at(index.row()));
    switch (role) {
    case TimeRole: return row.time;
    case PriorityRole: return row.priority;
    case SourceRole: return row.source;
    case DescriptionRole: return row.description;
    case StatusRole: return row.status;
    default: return {};
    }
}

QHash<int, QByteArray> AlarmController::roleNames() const
{
    return {
        {TimeRole, "time"},
        {PriorityRole, "priority"},
        {SourceRole, "source"},
        {DescriptionRole, "description"},
        {StatusRole, "status"}
    };
}

bool AlarmController::active() const { return m_active; }
QString AlarmController::priority() const { return m_priority; }
bool AlarmController::audioActive() const { return m_active && !m_silenced; }
int AlarmController::alarmCount() const { return m_filteredIndices.size(); }
QString AlarmController::headline() const { return m_headline; }
QString AlarmController::detail() const { return m_detail; }

void AlarmController::setActive(bool value)
{
    if (m_active == value)
        return;
    m_active = value;
    emit bannerChanged();
    emit audioChanged();
}

void AlarmController::setPriority(const QString &value)
{
    if (m_priority == value)
        return;
    m_priority = value;
    emit bannerChanged();
}

void AlarmController::setHeadline(const QString &value)
{
    if (m_headline == value)
        return;
    m_headline = value;
    emit bannerChanged();
}

void AlarmController::setDetail(const QString &value)
{
    if (m_detail == value)
        return;
    m_detail = value;
    emit bannerChanged();
}

QString AlarmController::filterPriority() const { return m_filterPriority; }

void AlarmController::setFilterPriority(const QString &priority)
{
    if (m_filterPriority == priority)
        return;
    beginResetModel();
    m_filterPriority = priority;
    rebuildFilteredIndices();
    endResetModel();
    emit filterChanged();
}

void AlarmController::rebuildFilteredIndices()
{
    m_filteredIndices.clear();
    for (int i = 0; i < m_rows.size(); ++i) {
        if (m_filterPriority.isEmpty()
            || m_rows.at(i).priority == m_filterPriority) {
            m_filteredIndices.append(i);
        }
    }
}

void AlarmController::addAlarm(const QString &priority,
                               const QString &source,
                               const QString &description,
                               const QString &status)
{
    // HARDWARE: In production, alarm events should also trigger GPIO outputs
    // for audible/visual alarm indicators (buzzer, LED panel) per IEC 60601-1-8.

    m_rows.prepend({
        QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss")),
        priority,
        source,
        description,
        status
    });

    // Rebuild filter and notify model of change.
    beginResetModel();
    rebuildFilteredIndices();
    endResetModel();

    if (m_database)
        m_database->logAlarm(priority, source, description, status);
}

void AlarmController::acknowledgeActiveAlarm()
{
    if (!m_active)
        return;
    addAlarm(m_priority, QStringLiteral("Operator"), m_headline, QStringLiteral("Acknowledged"));
    setActive(false);
    setPriority(QStringLiteral("Normal"));
    setHeadline(QStringLiteral("No Active Alarms"));
    setDetail(QStringLiteral("System normal"));
}

void AlarmController::silenceAlarms(int durationSeconds)
{
    // HARDWARE: Silence should mute the audio amplifier but keep visual indicators
    // active. Connect to audio DAC mute pin or amplifier enable GPIO.

    // IEC 60601-1-8: Critical alarms must not be silenced for more than 120 seconds.
    durationSeconds = qBound(10, durationSeconds, 120);
    m_silenced = true;
    m_silenceRemaining = durationSeconds;
    m_silenceTimer.start();
    emit silenceChanged();
    emit audioChanged();

    if (m_database) {
        m_database->logEvent(QStringLiteral("Alarm"),
                             QStringLiteral("Alarm audio silenced for ")
                                 + QString::number(durationSeconds)
                                 + QStringLiteral(" seconds"));
    }
}

void AlarmController::cancelSilence()
{
    if (!m_silenced)
        return;
    m_silenced = false;
    m_silenceRemaining = 0;
    m_silenceTimer.stop();
    emit silenceChanged();
    emit audioChanged();

    if (m_database) {
        m_database->logEvent(QStringLiteral("Alarm"),
                             QStringLiteral("Alarm silence cancelled by operator"));
    }
}

bool AlarmController::silenced() const { return m_silenced; }
int AlarmController::silenceRemaining() const { return m_silenceRemaining; }

int AlarmController::priorityWeight(const QString &priority)
{
    // IEC 60601-1-8 alarm priority ranking.
    // Higher weight = more urgent; used for arbitration when multiple alarms are active.
    if (priority == QStringLiteral("Critical"))
        return 3;
    if (priority == QStringLiteral("Warning"))
        return 2;
    if (priority == QStringLiteral("Info"))
        return 1;
    return 0;
}
