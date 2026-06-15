#pragma once

#include <QObject>
#include <QSettings>

/**
 * @brief Provides persistent application settings through QSettings.
 *
 * AppSettings stores device-demo metadata and UI preferences such as software
 * version, accumulated operating hours, language, brightness, and audio level.
 */
class AppSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString softwareVersion READ softwareVersion CONSTANT)
    Q_PROPERTY(double operatingHours READ operatingHours WRITE setOperatingHours NOTIFY operatingHoursChanged)
    Q_PROPERTY(int brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged)
    Q_PROPERTY(int audioVolume READ audioVolume WRITE setAudioVolume NOTIFY audioVolumeChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString dayNightMode READ dayNightMode WRITE setDayNightMode NOTIFY dayNightModeChanged)
    Q_PROPERTY(QString timeZoneId READ timeZoneId WRITE setTimeZoneId NOTIFY timeZoneIdChanged)
    Q_PROPERTY(int monitoringLayout READ monitoringLayout WRITE setMonitoringLayout NOTIFY monitoringLayoutChanged)
    Q_PROPERTY(int nightStartHour READ nightStartHour WRITE setNightStartHour NOTIFY dayNightScheduleChanged)
    Q_PROPERTY(int dayStartHour READ dayStartHour WRITE setDayStartHour NOTIFY dayNightScheduleChanged)

public:
    explicit AppSettings(QObject *parent = nullptr);

    /** @return Application software version string. */
    QString softwareVersion() const;
    /** @return Accumulated device operating hours. */
    double operatingHours() const;
    /** @return Display brightness level (0-100). */
    int brightness() const;
    /** @return Audio volume level (0-100). */
    int audioVolume() const;
    /** @return Current UI language identifier. */
    QString language() const;
    /** @return Day/Night display mode ("Day", "Night", or "Automatic"). */
    QString dayNightMode() const;
    /** @return Persisted IANA timezone identifier. */
    QString timeZoneId() const;
    /** @return Active monitoring layout preset (1-5). */
    int monitoringLayout() const;
    int nightStartHour() const;
    int dayStartHour() const;

public slots:
    /** @param hours Accumulated operating hours to store. */
    void setOperatingHours(double hours);
    /** @param value Display brightness level (0-100). */
    void setBrightness(int value);
    /** @param value Audio volume level (0-100). */
    void setAudioVolume(int value);
    /** @param value UI language identifier to apply. */
    void setLanguage(const QString &value);
    /** @param value Day/Night mode ("Day", "Night", or "Automatic"). */
    void setDayNightMode(const QString &value);
    /** @param value IANA timezone identifier to persist. */
    void setTimeZoneId(const QString &value);
    /** @param value Monitoring layout preset (1-5). */
    void setMonitoringLayout(int value);
    void setNightStartHour(int value);
    void setDayStartHour(int value);

signals:
    void operatingHoursChanged();
    void brightnessChanged();
    void audioVolumeChanged();
    void languageChanged();
    void dayNightModeChanged();
    void timeZoneIdChanged();
    void monitoringLayoutChanged();
    void dayNightScheduleChanged();

private:
    QSettings m_settings;
};
