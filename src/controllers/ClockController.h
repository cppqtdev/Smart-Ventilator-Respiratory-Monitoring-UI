#pragma once

#include <QObject>
#include <QTimer>
#include <QTimeZone>

/**
 * @brief Publishes the device date and time in the configured clinical timezone.
 *
 * The demo uses India Standard Time and a 12-hour clock to match the requested
 * ventilator display format. The class is intentionally tiny so it can later be
 * replaced by an RTC/NTP-backed device clock service.
 */
class ClockController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString dateText READ dateText NOTIFY timeChanged)
    Q_PROPERTY(QString timeText READ timeText NOTIFY timeChanged)
    Q_PROPERTY(QString dateTimeText READ dateTimeText NOTIFY timeChanged)

public:
    explicit ClockController(QObject *parent = nullptr);

    QString dateText() const;
    QString timeText() const;
    QString dateTimeText() const;

signals:
    void timeChanged();

private slots:
    void refresh();

private:
    QDateTime indiaTime() const;

    QTimer m_timer;
    QTimeZone m_timeZone;
    QString m_dateText;
    QString m_timeText;
};
