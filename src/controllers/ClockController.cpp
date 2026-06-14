#include "ClockController.h"

#include <QDateTime>
#include <QLocale>

ClockController::ClockController(QObject *parent)
    : QObject(parent)
    , m_timeZone("Asia/Kolkata")
{
    refresh();
    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &ClockController::refresh);
    m_timer.start();
}

QString ClockController::dateText() const
{
    return m_dateText;
}

QString ClockController::timeText() const
{
    return m_timeText;
}

QString ClockController::dateTimeText() const
{
    return m_dateText + QLatin1Char('\n') + m_timeText;
}

QString ClockController::timeZoneId() const
{
    return QString::fromLatin1(m_timeZone.id());
}

void ClockController::setTimeZoneId(const QString &id)
{
    const QTimeZone tz(id.toLatin1());
    if (!tz.isValid())
        return;
    if (m_timeZone == tz)
        return;
    m_timeZone = tz;
    emit timeZoneChanged();
    refresh();
}

QStringList ClockController::availableTimeZones() const
{
    return {
        QStringLiteral("Asia/Kolkata"),
        QStringLiteral("UTC"),
        QStringLiteral("America/New_York"),
        QStringLiteral("America/Chicago"),
        QStringLiteral("America/Los_Angeles"),
        QStringLiteral("Europe/London"),
        QStringLiteral("Europe/Berlin"),
        QStringLiteral("Asia/Tokyo"),
        QStringLiteral("Australia/Sydney")
    };
}

void ClockController::refresh()
{
    const QDateTime now = currentZonedTime();
    const QString nextDate = QLocale(QLocale::English).toString(
        now.date(), QStringLiteral("dd-MMM-yyyy"));
    const QString nextTime = QLocale(QLocale::English).toString(
        now.time(), QStringLiteral("hh:mm AP"));

    if (nextDate == m_dateText && nextTime == m_timeText)
        return;

    m_dateText = nextDate;
    m_timeText = nextTime;
    emit timeChanged();
}

QDateTime ClockController::currentZonedTime() const
{
    return QDateTime::currentDateTimeUtc().toTimeZone(m_timeZone);
}
