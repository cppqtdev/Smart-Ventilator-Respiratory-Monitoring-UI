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

void ClockController::refresh()
{
    const QDateTime now = indiaTime();
    const QString nextDate = QLocale(QLocale::English).toString(now.date(), QStringLiteral("dd-MMM-yyyy"));
    const QString nextTime = QLocale(QLocale::English).toString(now.time(), QStringLiteral("hh:mm AP"));

    if (nextDate == m_dateText && nextTime == m_timeText)
        return;

    m_dateText = nextDate;
    m_timeText = nextTime;
    emit timeChanged();
}

QDateTime ClockController::indiaTime() const
{
    return QDateTime::currentDateTimeUtc().toTimeZone(m_timeZone);
}
