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

public slots:
    /** @param hours Accumulated operating hours to store. */
    void setOperatingHours(double hours);
    /** @param value Display brightness level (0-100). */
    void setBrightness(int value);
    /** @param value Audio volume level (0-100). */
    void setAudioVolume(int value);
    /** @param value UI language identifier to apply. */
    void setLanguage(const QString &value);

signals:
    void operatingHoursChanged();
    void brightnessChanged();
    void audioVolumeChanged();
    void languageChanged();

private:
    QSettings m_settings;
};
