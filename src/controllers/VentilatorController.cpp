#include "VentilatorController.h"

#include "AlarmController.h"
#include "src/core/DatabaseManager.h"

#include <QtMath>

namespace {
double clampDouble(double value, double low, double high)
{
    return qMax(low, qMin(high, value));
}
}

VentilatorController::VentilatorController(DatabaseManager *database,
                                           AlarmController *alarmController,
                                           QObject *parent)
    : QObject(parent)
    , m_database(database)
    , m_alarmController(alarmController)
{
    m_sampleTimer.setInterval(45);
    connect(&m_sampleTimer, &QTimer::timeout, this, &VentilatorController::updateSimulation);

    m_ventilationTimer.setInterval(1000);
    connect(&m_ventilationTimer, &QTimer::timeout, this, [this]() {
        ++m_ventilationSeconds;
        emit measurementsChanged();
    });
}

bool VentilatorController::running() const { return m_running; }
bool VentilatorController::frozen() const { return m_frozen; }
QString VentilatorController::mode() const { return m_mode; }
int VentilatorController::fio2() const { return m_fio2; }
int VentilatorController::peep() const { return m_peep; }
int VentilatorController::pressureSupport() const { return m_pressureSupport; }
int VentilatorController::inspiratoryTime() const { return m_inspiratoryTime; }
int VentilatorController::respiratoryRate() const { return m_respiratoryRate; }
int VentilatorController::trigger() const { return m_trigger; }
int VentilatorController::minuteVolume() const { return m_minuteVolume; }
int VentilatorController::tidalVolume() const { return m_tidalVolume; }
double VentilatorController::ppeak() const { return m_ppeak; }
double VentilatorController::pplat() const { return m_pplat; }
double VentilatorController::pmean() const { return m_pmean; }
double VentilatorController::spo2() const { return m_spo2; }
double VentilatorController::etco2() const { return m_etco2; }
double VentilatorController::compliance() const { return m_compliance; }
double VentilatorController::resistance() const { return m_resistance; }
double VentilatorController::vte() const { return m_vte; }
double VentilatorController::ftotal() const { return m_ftotal; }
double VentilatorController::rcexp() const { return m_rcexp; }
double VentilatorController::expMinVol() const { return m_expMinVol; }
int VentilatorController::ventilationSeconds() const { return m_ventilationSeconds; }

QString VentilatorController::ventilationTime() const
{
    int h = m_ventilationSeconds / 3600;
    int m = (m_ventilationSeconds % 3600) / 60;
    int s = m_ventilationSeconds % 60;
    return QStringLiteral("%1:%2:%3")
        .arg(h, 2, 10, QLatin1Char('0'))
        .arg(m, 2, 10, QLatin1Char('0'))
        .arg(s, 2, 10, QLatin1Char('0'));
}
QVariantList VentilatorController::pressureWaveform() const { return m_pressureWaveform; }
QVariantList VentilatorController::flowWaveform() const { return m_flowWaveform; }
QVariantList VentilatorController::volumeWaveform() const { return m_volumeWaveform; }
QVariantList VentilatorController::co2Waveform() const { return m_co2Waveform; }

void VentilatorController::startVentilation()
{
    if (m_running)
        return;
    m_running = true;
    m_ventilationSeconds = 0;
    m_sampleTimer.start();
    m_ventilationTimer.start();
    if (m_database)
        m_database->logEvent(QStringLiteral("Ventilation"), QStringLiteral("Ventilation started"), QStringLiteral("Active"));
    emit runningChanged();
}

void VentilatorController::stopVentilation()
{
    if (!m_running)
        return;
    m_running = false;
    m_sampleTimer.stop();
    m_ventilationTimer.stop();
    m_pressureWaveform.clear();
    m_flowWaveform.clear();
    m_volumeWaveform.clear();
    m_co2Waveform.clear();
    m_ppeak = m_pplat = m_pmean = m_spo2 = m_etco2 = m_compliance = m_resistance = 0;
    m_vte = m_ftotal = m_rcexp = m_expMinVol = 0;
    if (m_database)
        m_database->logEvent(QStringLiteral("Ventilation"), QStringLiteral("Ventilation stopped"), QStringLiteral("Standby"));
    emit runningChanged();
    emit measurementsChanged();
    emit waveformChanged();
}

void VentilatorController::toggleFreeze()
{
    m_frozen = !m_frozen;
    if (m_database)
        m_database->logEvent(QStringLiteral("Monitoring"), m_frozen ? QStringLiteral("Waveforms frozen") : QStringLiteral("Waveforms resumed"));
    emit frozenChanged();
}

void VentilatorController::runCalibration()
{
    if (m_database)
        m_database->logEvent(QStringLiteral("Calibration"), QStringLiteral("Pressure, flow and oxygen checks completed"), QStringLiteral("Passed"));
}

void VentilatorController::setMode(const QString &value)
{
    if (m_mode == value)
        return;
    m_mode = value;
    if (m_database)
        m_database->logEvent(QStringLiteral("Mode"), QStringLiteral("Mode changed to ") + value);
    emit settingsChanged();
}

void VentilatorController::setFio2(int value)
{
    value = qBound(21, value, 100);
    if (m_fio2 == value)
        return;
    m_fio2 = value;
    emit settingsChanged();
}

void VentilatorController::setPeep(int value)
{
    value = qBound(0, value, 30);
    if (m_peep == value)
        return;
    m_peep = value;
    emit settingsChanged();
}

void VentilatorController::setPressureSupport(int value)
{
    value = qBound(0, value, 40);
    if (m_pressureSupport == value)
        return;
    m_pressureSupport = value;
    emit settingsChanged();
}

void VentilatorController::setInspiratoryTime(int value)
{
    value = qBound(1, value, 5);
    if (m_inspiratoryTime == value)
        return;
    m_inspiratoryTime = value;
    emit settingsChanged();
}

void VentilatorController::setRespiratoryRate(int value)
{
    value = qBound(4, value, 60);
    if (m_respiratoryRate == value)
        return;
    m_respiratoryRate = value;
    emit settingsChanged();
}

void VentilatorController::setTrigger(int value)
{
    value = qBound(1, value, 10);
    if (m_trigger == value)
        return;
    m_trigger = value;
    emit settingsChanged();
}

void VentilatorController::setMinuteVolume(int value)
{
    value = qBound(20, value, 400);
    if (m_minuteVolume == value)
        return;
    m_minuteVolume = value;
    emit settingsChanged();
}

void VentilatorController::setTidalVolume(int value)
{
    value = qBound(20, value, 900);
    if (m_tidalVolume == value)
        return;
    m_tidalVolume = value;
    emit settingsChanged();
}

void VentilatorController::appendSample(QVariantList &buffer, double value)
{
    buffer.append(value);
    constexpr int maxSamples = 180;
    while (buffer.size() > maxSamples)
        buffer.removeFirst();
}

void VentilatorController::updateSimulation()
{
    if (!m_running || m_frozen)
        return;

    ++m_sampleIndex;
    const double dt = m_sampleTimer.interval() / 1000.0;
    const double rr = clampDouble(m_respiratoryRate, 6, 45);
    m_phase = std::fmod(m_phase + dt * rr / 60.0, 1.0);

    const double inspiratoryFraction = clampDouble(0.28 + m_inspiratoryTime * 0.05, 0.24, 0.46);
    const bool inspiration = m_phase < inspiratoryFraction;
    const double normalized = inspiration ? m_phase / inspiratoryFraction : (m_phase - inspiratoryFraction) / (1.0 - inspiratoryFraction);
    const double effort = std::sin(m_sampleIndex * 0.037) * 0.7 + std::sin(m_sampleIndex * 0.011) * 0.4;
    const double pressureTarget = m_peep + m_pressureSupport + m_tidalVolume / 55.0;

    const double paw = inspiration
        ? m_peep + (pressureTarget - m_peep) * (1.0 - std::exp(-normalized * 6.0)) + effort
        : m_peep + (pressureTarget - m_peep) * std::exp(-normalized * 9.0) + effort * 0.35;
    const double flowPeak = m_tidalVolume / 7.0;
    const double flow = inspiration
        ? flowPeak * (1.0 - normalized * 0.7) + effort * 3.0
        : -flowPeak * 0.72 * std::sin(M_PI * normalized) * std::exp(-normalized * 0.35) + effort * 2.0;
    const double volume = inspiration
        ? m_tidalVolume * std::sin(normalized * M_PI / 2.0)
        : m_tidalVolume * std::exp(-normalized * 4.4);

    const double slow = std::sin(m_sampleIndex * 0.021);
    const double fio2Effect = (m_fio2 - 21.0) / 79.0;
    m_ppeak = qRound(clampDouble(pressureTarget + 6.0 + slow * 2.2, 8, 58));
    m_pplat = qRound(clampDouble(pressureTarget + 1.5 + slow, 6, 45));
    m_pmean = qRound(clampDouble(m_peep + m_pressureSupport * 0.45 + slow, 4, 35));
    m_spo2 = qRound(clampDouble(92.0 + fio2Effect * 8.0 - qMax(0, m_peep - 18) * 0.15 + std::sin(m_sampleIndex * 0.013), 84, 100));
    m_etco2 = qRound(clampDouble(31.0 + std::sin(m_sampleIndex * 0.018) * 3.0 - (m_minuteVolume - 100.0) * 0.025, 18, 55));
    m_compliance = qRound(clampDouble(m_tidalVolume / qMax(1.0, m_pplat - m_peep) + std::sin(m_sampleIndex * 0.017) * 4.0, 12, 95));
    m_resistance = qRound(clampDouble(8.0 + m_trigger * 0.8 + std::sin(m_sampleIndex * 0.029) * 2.0, 3, 28));

    // Derived respiratory mechanics (per Behance design metrics)
    m_vte = qRound(clampDouble(m_tidalVolume * (0.92 + std::sin(m_sampleIndex * 0.023) * 0.06), 50, 900));
    m_ftotal = qRound(clampDouble(rr + std::sin(m_sampleIndex * 0.019) * 1.5, 4, 60));
    m_rcexp = clampDouble(m_compliance * m_resistance / 1000.0 + std::sin(m_sampleIndex * 0.031) * 0.08, 0.1, 2.5);
    m_rcexp = std::round(m_rcexp * 100.0) / 100.0;
    m_expMinVol = clampDouble(m_vte * m_ftotal / 1000.0, 0.5, 30.0);
    m_expMinVol = std::round(m_expMinVol * 10.0) / 10.0;
    const double co2 = inspiration
        ? qMax(0.0, m_etco2 * std::exp(-normalized * 6.0) - 2.0)
        : m_etco2 * (1.0 - std::exp(-normalized * 8.0)) + std::sin(m_sampleIndex * 0.08);

    appendSample(m_pressureWaveform, paw);
    appendSample(m_flowWaveform, flow);
    appendSample(m_volumeWaveform, volume / 10.0);
    appendSample(m_co2Waveform, co2);

    evaluateAlarms();
    saveSnapshotIfDue();
    emit measurementsChanged();
    emit waveformChanged();
}

void VentilatorController::evaluateAlarms()
{
    if (!m_alarmController)
        return;

    if (m_ppeak > 42) {
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Critical"));
        m_alarmController->setHeadline(QStringLiteral("High Pressure"));
        m_alarmController->setDetail(QStringLiteral("Paw above limit"));
        return;
    }

    if (m_minuteVolume > 145) {
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Critical"));
        m_alarmController->setHeadline(QStringLiteral("High Minute Volume"));
        m_alarmController->setDetail(QStringLiteral("CT Low"));
        return;
    }

    m_alarmController->setActive(false);
    m_alarmController->setPriority(QStringLiteral("Normal"));
    m_alarmController->setHeadline(QStringLiteral("No Active Alarms"));
    m_alarmController->setDetail(QStringLiteral("System normal"));
}

QVariantMap VentilatorController::snapshot() const
{
    return {
        {QStringLiteral("mode"), m_mode},
        {QStringLiteral("fio2"), m_fio2},
        {QStringLiteral("peep"), m_peep},
        {QStringLiteral("pressureSupport"), m_pressureSupport},
        {QStringLiteral("respiratoryRate"), m_respiratoryRate},
        {QStringLiteral("minuteVolume"), m_minuteVolume},
        {QStringLiteral("tidalVolume"), m_tidalVolume},
        {QStringLiteral("ppeak"), m_ppeak},
        {QStringLiteral("pplat"), m_pplat},
        {QStringLiteral("pmean"), m_pmean},
        {QStringLiteral("spo2"), m_spo2},
        {QStringLiteral("etco2"), m_etco2},
        {QStringLiteral("compliance"), m_compliance},
        {QStringLiteral("resistance"), m_resistance}
    };
}

void VentilatorController::saveSnapshotIfDue()
{
    if (!m_database)
        return;
    ++m_snapshotCounter;
    if (m_snapshotCounter < 25)
        return;
    m_snapshotCounter = 0;
    m_database->saveParameterSnapshot(snapshot());
}
