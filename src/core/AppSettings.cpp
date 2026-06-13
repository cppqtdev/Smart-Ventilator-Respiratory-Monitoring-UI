#include "AppSettings.h"

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_settings(QStringLiteral("AlsonsTechnology"), QStringLiteral("SmartVentilatorDemo"))
{
}

QString AppSettings::softwareVersion() const
{
    return QStringLiteral("5.6b");
}

double AppSettings::operatingHours() const
{
    return m_settings.value(QStringLiteral("device/operatingHours"), 82.11).toDouble();
}

int AppSettings::brightness() const
{
    return m_settings.value(QStringLiteral("ui/brightness"), 85).toInt();
}

int AppSettings::audioVolume() const
{
    return m_settings.value(QStringLiteral("ui/audioVolume"), 70).toInt();
}

QString AppSettings::language() const
{
    return m_settings.value(QStringLiteral("ui/language"), QStringLiteral("English")).toString();
}

void AppSettings::setOperatingHours(double hours)
{
    if (qFuzzyCompare(operatingHours(), hours))
        return;
    m_settings.setValue(QStringLiteral("device/operatingHours"), hours);
    emit operatingHoursChanged();
}

void AppSettings::setBrightness(int value)
{
    if (brightness() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/brightness"), value);
    emit brightnessChanged();
}

void AppSettings::setAudioVolume(int value)
{
    if (audioVolume() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/audioVolume"), value);
    emit audioVolumeChanged();
}

void AppSettings::setLanguage(const QString &value)
{
    if (language() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/language"), value);
    emit languageChanged();
}
