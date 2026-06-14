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
    Q_PROPERTY(QString timeZoneId READ timeZoneId WRITE setTimeZoneId NOTIFY timeZoneChanged)

public:
    explicit ClockController(QObject *parent = nullptr);

    /** @return Formatted date string in the configured timezone. */
    QString dateText() const;
    /** @return Formatted time string in the configured timezone. */
    QString timeText() const;
    /** @return Combined date and time string in the configured timezone. */
    QString dateTimeText() const;
    /** @return Current IANA timezone identifier (e.g. "Asia/Kolkata"). */
    QString timeZoneId() const;

    /** @brief Sets the display timezone by IANA identifier (e.g. "America/New_York"). */
    Q_INVOKABLE void setTimeZoneId(const QString &id);

    /** @return List of common IANA timezone identifiers for UI selection. */
    Q_INVOKABLE QStringList availableTimeZones() const;

signals:
    void timeChanged();
    void timeZoneChanged();

private slots:
    void refresh();

private:
    QDateTime currentZonedTime() const;

    QTimer m_timer;
    QTimeZone m_timeZone;
    QString m_dateText;
    QString m_timeText;
};
