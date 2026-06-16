#include "AppSettings.h"

#include <QDebug>

namespace {
void syncSettings(QSettings &settings, const QString &key)
{
    settings.sync();
    if (settings.status() != QSettings::NoError)
        qWarning() << "Failed to persist setting" << key << "status" << settings.status();
}
}

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

QString AppSettings::dayNightMode() const
{
    return m_settings.value(QStringLiteral("ui/dayNightMode"), QStringLiteral("Day")).toString();
}

QString AppSettings::timeZoneId() const
{
    return m_settings.value(QStringLiteral("ui/timeZoneId"), QStringLiteral("Asia/Kolkata")).toString();
}

int AppSettings::monitoringLayout() const
{
    return m_settings.value(QStringLiteral("ui/monitoringLayout"), 1).toInt();
}

int AppSettings::nightStartHour() const
{
    return m_settings.value(QStringLiteral("ui/nightStartHour"), 20).toInt();
}

int AppSettings::dayStartHour() const
{
    return m_settings.value(QStringLiteral("ui/dayStartHour"), 6).toInt();
}

void AppSettings::setOperatingHours(double hours)
{
    if (qFuzzyCompare(operatingHours(), hours))
        return;
    m_settings.setValue(QStringLiteral("device/operatingHours"), hours);
    syncSettings(m_settings, QStringLiteral("device/operatingHours"));
    emit operatingHoursChanged();
}

void AppSettings::setBrightness(int value)
{
    if (brightness() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/brightness"), value);
    syncSettings(m_settings, QStringLiteral("ui/brightness"));
    emit brightnessChanged();
}

void AppSettings::setAudioVolume(int value)
{
    if (audioVolume() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/audioVolume"), value);
    syncSettings(m_settings, QStringLiteral("ui/audioVolume"));
    emit audioVolumeChanged();
}

void AppSettings::setLanguage(const QString &value)
{
    if (language() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/language"), value);
    syncSettings(m_settings, QStringLiteral("ui/language"));
    emit languageChanged();
}

void AppSettings::setDayNightMode(const QString &value)
{
    if (dayNightMode() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/dayNightMode"), value);
    syncSettings(m_settings, QStringLiteral("ui/dayNightMode"));
    emit dayNightModeChanged();
}

void AppSettings::setTimeZoneId(const QString &value)
{
    if (timeZoneId() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/timeZoneId"), value);
    syncSettings(m_settings, QStringLiteral("ui/timeZoneId"));
    emit timeZoneIdChanged();
}

void AppSettings::setMonitoringLayout(int value)
{
    value = qBound(1, value, 5);
    if (monitoringLayout() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/monitoringLayout"), value);
    syncSettings(m_settings, QStringLiteral("ui/monitoringLayout"));
    emit monitoringLayoutChanged();
}

void AppSettings::setNightStartHour(int value)
{
    value = qBound(0, value, 23);
    if (nightStartHour() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/nightStartHour"), value);
    syncSettings(m_settings, QStringLiteral("ui/nightStartHour"));
    emit dayNightScheduleChanged();
}

void AppSettings::setDayStartHour(int value)
{
    value = qBound(0, value, 23);
    if (dayStartHour() == value)
        return;
    m_settings.setValue(QStringLiteral("ui/dayStartHour"), value);
    syncSettings(m_settings, QStringLiteral("ui/dayStartHour"));
    emit dayNightScheduleChanged();
}
