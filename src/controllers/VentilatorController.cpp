#include "VentilatorController.h"

#include "AlarmController.h"
#include "src/core/DatabaseManager.h"

#include <QtMath>
#include <QSet>

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

    m_lastHardwareHeartbeatUtc = QDateTime::currentDateTimeUtc();
    m_backendWatchdogTimer.setInterval(1000);
    connect(&m_backendWatchdogTimer, &QTimer::timeout,
            this, &VentilatorController::checkBackendHeartbeat);
    m_backendWatchdogTimer.start();
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

double VentilatorController::drivingPressure() const
{
    // Driving pressure = Pplat - PEEP. Target < 15 cmH2O for lung protection.
    return qMax(0.0, m_pplat - m_peep);
}

QString VentilatorController::ieRatio() const
{
    // I:E ratio derived from inspiratory time and respiratory rate.
    double totalCycle = 60.0 / qMax(1, m_respiratoryRate);
    double insp = qMax(0.3, static_cast<double>(m_inspiratoryTime));
    double exp = totalCycle - insp;
    if (exp <= 0) return QStringLiteral("1:0");
    return QStringLiteral("1:%1").arg(exp / insp, 0, 'f', 1);
}

double VentilatorController::workOfBreathing() const { return m_workOfBreathing; }
double VentilatorController::stressIndex() const { return m_stressIndex; }
double VentilatorController::deadSpaceFraction() const { return m_deadSpaceFraction; }
int VentilatorController::highFio2Minutes() const { return m_highFio2Minutes; }
bool VentilatorController::patientDisconnected() const { return m_patientDisconnected; }
bool VentilatorController::circuitOcclusion() const { return m_circuitOcclusion; }

int VentilatorController::ventilationSeconds() const { return m_ventilationSeconds; }
int VentilatorController::alarmHighPressure() const { return m_alarmHighPressure; }
int VentilatorController::alarmLowPressure() const { return m_alarmLowPressure; }
int VentilatorController::alarmApneaTime() const { return m_alarmApneaTime; }
int VentilatorController::alarmLowVt() const { return m_alarmLowVt; }
int VentilatorController::alarmHighMv() const { return m_alarmHighMv; }
int VentilatorController::alarmLowSpo2() const { return m_alarmLowSpo2; }
bool VentilatorController::apneaBackupEnabled() const { return m_apneaBackupEnabled; }

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
QString VentilatorController::lastCommandMessage() const { return m_lastCommandMessage; }
QString VentilatorController::operatorId() const { return m_operatorId; }
QString VentilatorController::patientCategory() const { return m_patientCategory; }
int VentilatorController::patientIbwKg() const { return m_patientIbwKg; }
bool VentilatorController::backendConnected() const { return m_backendConnected; }
bool VentilatorController::degradedMode() const { return m_degradedMode; }
QString VentilatorController::backendState() const { return m_backendState; }
QVariantList VentilatorController::pressureWaveform() const { return m_pressureWaveform; }
QVariantList VentilatorController::flowWaveform() const { return m_flowWaveform; }
QVariantList VentilatorController::volumeWaveform() const { return m_volumeWaveform; }
QVariantList VentilatorController::co2Waveform() const { return m_co2Waveform; }

void VentilatorController::startVentilation()
{
    QString reason;
    if (!validateStart(&reason)) {
        setCommandMessage(reason);
        emit commandRejected(reason);
        return;
    }
    if (m_running)
        return;
    if (m_degradedMode) {
        const QString message = QStringLiteral("Cannot start: backend is in degraded mode");
        setCommandMessage(message);
        emit commandRejected(message);
        return;
    }
    m_running = true;
    m_ventilationSeconds = 0;
    m_sampleTimer.start();
    m_ventilationTimer.start();
    if (m_database)
        m_database->logEvent(QStringLiteral("Ventilation"), QStringLiteral("Ventilation started"), QStringLiteral("Active"));
    emit runningChanged();
}

bool VentilatorController::requestStartVentilation()
{
    QString reason;
    if (!validateStart(&reason)) {
        setCommandMessage(reason);
        emit commandRejected(reason);
        return false;
    }
    startVentilation();
    setCommandMessage(QStringLiteral("Ventilation started"));
    return true;
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
    m_workOfBreathing = 0; m_stressIndex = 1.0; m_deadSpaceFraction = 0.3;
    m_patientDisconnected = false; m_circuitOcclusion = false;
    if (m_database)
        m_database->logEvent(QStringLiteral("Ventilation"), QStringLiteral("Ventilation stopped"), QStringLiteral("Standby"));
    emit runningChanged();
    emit measurementsChanged();
    emit waveformChanged();
}

void VentilatorController::setOperatorId(const QString &operatorId)
{
    const QString normalized = operatorId.trimmed().isEmpty()
        ? QStringLiteral("unauthenticated")
        : operatorId.trimmed();
    if (m_operatorId == normalized)
        return;
    m_operatorId = normalized;
    emit operatorChanged();
}

void VentilatorController::setPatientContext(const QString &category)
{
    const QString normalized = category.trimmed().isEmpty()
        ? QStringLiteral("Adult")
        : category.trimmed();
    if (m_patientCategory == normalized)
        return;
    m_patientCategory = normalized;
    setCommandMessage(QStringLiteral("Patient category set to %1").arg(normalized));
    emit patientContextChanged();
}

void VentilatorController::setPatientIbwKg(int ibwKg)
{
    ibwKg = qBound(1, ibwKg, 180);
    if (m_patientIbwKg == ibwKg)
        return;
    m_patientIbwKg = ibwKg;
    emit patientContextChanged();
}

void VentilatorController::recordHardwareHeartbeat()
{
    m_lastHardwareHeartbeatUtc = QDateTime::currentDateTimeUtc();
    if (!m_backendConnected || m_degradedMode) {
        m_backendConnected = true;
        setDegradedMode(false, QStringLiteral("Simulator connected"));
    }
}

void VentilatorController::setBackendConnected(bool connected)
{
    m_backendConnected = connected;
    if (connected) {
        m_lastHardwareHeartbeatUtc = QDateTime::currentDateTimeUtc();
        setDegradedMode(false, QStringLiteral("Simulator connected"));
    } else {
        setDegradedMode(true, QStringLiteral("Backend disconnected"));
    }
    emit backendStateChanged();
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
    requestModeChange(value);
}

void VentilatorController::setFio2(int value)
{
    applyParameterChange(QStringLiteral("fio2"), value, false);
}

void VentilatorController::setPeep(int value)
{
    applyParameterChange(QStringLiteral("peep"), value, false);
}

void VentilatorController::setPressureSupport(int value)
{
    applyParameterChange(QStringLiteral("pressureSupport"), value, false);
}

void VentilatorController::setInspiratoryTime(int value)
{
    applyParameterChange(QStringLiteral("inspiratoryTime"), value, false);
}

void VentilatorController::setRespiratoryRate(int value)
{
    applyParameterChange(QStringLiteral("respiratoryRate"), value, false);
}

void VentilatorController::setTrigger(int value)
{
    applyParameterChange(QStringLiteral("trigger"), value, false);
}

void VentilatorController::setMinuteVolume(int value)
{
    applyParameterChange(QStringLiteral("minuteVolume"), value, false);
}

void VentilatorController::setTidalVolume(int value)
{
    applyParameterChange(QStringLiteral("tidalVolume"), value, false);
}

void VentilatorController::setAlarmHighPressure(int value)
{
    applyAlarmLimitChange(QStringLiteral("highPressure"), value, false);
}

void VentilatorController::setAlarmLowPressure(int value)
{
    applyAlarmLimitChange(QStringLiteral("lowPressure"), value, false);
}

void VentilatorController::setAlarmApneaTime(int value)
{
    applyAlarmLimitChange(QStringLiteral("apneaTime"), value, false);
}

void VentilatorController::setAlarmLowVt(int value)
{
    applyAlarmLimitChange(QStringLiteral("lowVt"), value, false);
}

void VentilatorController::setAlarmHighMv(int value)
{
    applyAlarmLimitChange(QStringLiteral("highMv"), value, false);
}

void VentilatorController::setAlarmLowSpo2(int value)
{
    applyAlarmLimitChange(QStringLiteral("lowSpo2"), value, false);
}

void VentilatorController::setApneaBackupEnabled(bool value)
{
    requestApneaBackupChange(value);
}

bool VentilatorController::requestModeChange(const QString &mode)
{
    QString reason;
    if (!validateMode(mode, &reason)) {
        setCommandMessage(reason);
        emit commandRejected(reason);
        return false;
    }
    if (m_mode == mode)
        return true;
    const QString oldMode = m_mode;
    m_mode = mode;
    logSettingChange(QStringLiteral("Mode"), oldMode, mode);
    setCommandMessage(QStringLiteral("Mode changed to %1").arg(mode));
    emit settingsChanged();
    return true;
}

bool VentilatorController::requestApneaBackupChange(bool enabled)
{
    if (m_apneaBackupEnabled == enabled)
        return true;
    const bool oldValue = m_apneaBackupEnabled;
    m_apneaBackupEnabled = enabled;
    logSettingChange(QStringLiteral("Apnea backup"), oldValue, enabled);
    setCommandMessage(enabled ? QStringLiteral("Apnea backup enabled")
                              : QStringLiteral("Apnea backup disabled"));
    emit settingsChanged();
    return true;
}

bool VentilatorController::requestParameterChange(const QString &parameter, int value)
{
    return applyParameterChange(parameter, value, true);
}

bool VentilatorController::requestAlarmLimitChange(const QString &limit, int value)
{
    return applyAlarmLimitChange(limit, value, true);
}

bool VentilatorController::applyParameterChange(const QString &parameter, int value, bool audited)
{
    int *target = nullptr;
    int low = 0;
    int high = 0;
    QString label;
    QString unit;

    if (parameter == QStringLiteral("fio2")) {
        target = &m_fio2; low = 21; high = 100; label = QStringLiteral("FiO2"); unit = QStringLiteral("%");
    } else if (parameter == QStringLiteral("peep")) {
        target = &m_peep; low = 0; high = qMin(30, m_alarmHighPressure - 5); label = QStringLiteral("PEEP"); unit = QStringLiteral("cmH2O");
    } else if (parameter == QStringLiteral("pressureSupport")) {
        target = &m_pressureSupport; low = 0; high = 40; label = QStringLiteral("Pressure support"); unit = QStringLiteral("cmH2O");
    } else if (parameter == QStringLiteral("inspiratoryTime")) {
        target = &m_inspiratoryTime; low = 1; high = 5; label = QStringLiteral("Inspiratory time"); unit = QStringLiteral("s");
    } else if (parameter == QStringLiteral("respiratoryRate")) {
        target = &m_respiratoryRate; low = categoryMinRr(); high = categoryMaxRr(); label = QStringLiteral("Respiratory rate"); unit = QStringLiteral("1/min");
    } else if (parameter == QStringLiteral("trigger")) {
        target = &m_trigger; low = 1; high = 10; label = QStringLiteral("Trigger"); unit = QStringLiteral("L/min");
    } else if (parameter == QStringLiteral("minuteVolume")) {
        target = &m_minuteVolume; low = 20; high = 400; label = QStringLiteral("%MinVol"); unit = QStringLiteral("%");
    } else if (parameter == QStringLiteral("tidalVolume")) {
        target = &m_tidalVolume; low = categoryMinVt(); high = categoryMaxVt(); label = QStringLiteral("Tidal volume"); unit = QStringLiteral("mL");
    }

    if (!target) {
        const QString message = QStringLiteral("Unknown parameter: %1").arg(parameter);
        setCommandMessage(message);
        emit commandRejected(message);
        return false;
    }

    const int requested = value;
    value = qBound(low, value, high);
    if (requested != value) {
        const QString message = QStringLiteral("%1 limited to %2 %3").arg(label).arg(value).arg(unit);
        setCommandMessage(message);
        emit commandRejected(message);
        return false;
    }

    QString envelopeReason;
    if (!validateSettingEnvelope(parameter, value, &envelopeReason)) {
        setCommandMessage(envelopeReason);
        emit commandRejected(envelopeReason);
        return false;
    }

    if (*target == value)
        return true;
    const int oldValue = *target;
    *target = value;
    if (audited)
        logSettingChange(label, oldValue, QStringLiteral("%1 %2").arg(value).arg(unit));
    setCommandMessage(QStringLiteral("%1 set to %2 %3").arg(label).arg(value).arg(unit));
    emit settingsChanged();
    evaluateAlarms();
    return true;
}

bool VentilatorController::applyAlarmLimitChange(const QString &limit, int value, bool audited)
{
    int *target = nullptr;
    int low = 0;
    int high = 0;
    QString label;
    QString unit;

    if (limit == QStringLiteral("highPressure")) {
        target = &m_alarmHighPressure; low = qMax(10, m_alarmLowPressure + 5); high = 80; label = QStringLiteral("High pressure alarm"); unit = QStringLiteral("cmH2O");
    } else if (limit == QStringLiteral("lowPressure")) {
        target = &m_alarmLowPressure; low = 0; high = qMin(40, m_alarmHighPressure - 5); label = QStringLiteral("Low pressure alarm"); unit = QStringLiteral("cmH2O");
    } else if (limit == QStringLiteral("apneaTime")) {
        target = &m_alarmApneaTime; low = 5; high = 60; label = QStringLiteral("Apnea time alarm"); unit = QStringLiteral("s");
    } else if (limit == QStringLiteral("lowVt")) {
        target = &m_alarmLowVt; low = 20; high = qMax(20, m_tidalVolume - 20); label = QStringLiteral("Low VT alarm"); unit = QStringLiteral("mL");
    } else if (limit == QStringLiteral("highMv")) {
        target = &m_alarmHighMv; low = 1; high = 30; label = QStringLiteral("High MV alarm"); unit = QStringLiteral("L/min");
    } else if (limit == QStringLiteral("lowSpo2")) {
        target = &m_alarmLowSpo2; low = 70; high = 100; label = QStringLiteral("Low SpO2 alarm"); unit = QStringLiteral("%");
    }

    if (!target) {
        const QString message = QStringLiteral("Unknown alarm limit: %1").arg(limit);
        setCommandMessage(message);
        emit commandRejected(message);
        return false;
    }

    const int requested = value;
    value = qBound(low, value, high);
    if (requested != value) {
        const QString message = QStringLiteral("%1 limited to %2 %3").arg(label).arg(value).arg(unit);
        setCommandMessage(message);
        emit commandRejected(message);
        return false;
    }

    if (*target == value)
        return true;
    const int oldValue = *target;
    *target = value;
    if (audited)
        logSettingChange(label, oldValue, QStringLiteral("%1 %2").arg(value).arg(unit));
    setCommandMessage(QStringLiteral("%1 set to %2 %3").arg(label).arg(value).arg(unit));
    emit settingsChanged();
    evaluateAlarms();
    return true;
}

bool VentilatorController::validateMode(const QString &mode, QString *reason) const
{
    static const QSet<QString> supportedModes = {
        QStringLiteral("VCV"), QStringLiteral("PCV"), QStringLiteral("SIMV"),
        QStringLiteral("CPAP"), QStringLiteral("BiPAP"), QStringLiteral("ASV"),
        QStringLiteral("PRVC"), QStringLiteral("PSV")
    };
    if (!supportedModes.contains(mode)) {
        if (reason)
            *reason = QStringLiteral("Unsupported ventilation mode: %1").arg(mode);
        return false;
    }
    return true;
}

bool VentilatorController::validateStart(QString *reason) const
{
    if (m_degradedMode) {
        if (reason)
            *reason = QStringLiteral("Cannot start: backend communication is degraded");
        return false;
    }
    if (m_alarmLowPressure >= m_alarmHighPressure) {
        if (reason)
            *reason = QStringLiteral("Cannot start: pressure alarm limits are invalid");
        return false;
    }
    if (m_peep >= m_alarmHighPressure) {
        if (reason)
            *reason = QStringLiteral("Cannot start: PEEP is above the high pressure alarm limit");
        return false;
    }
    if (m_peep + m_pressureSupport + 5 >= m_alarmHighPressure) {
        if (reason)
            *reason = QStringLiteral("Cannot start: pressure support plus PEEP is too close to high pressure alarm");
        return false;
    }
    if (m_tidalVolume < 20 || m_respiratoryRate < 4 || m_fio2 < 21) {
        if (reason)
            *reason = QStringLiteral("Cannot start: ventilator settings are incomplete");
        return false;
    }
    return validateSettingEnvelope(QStringLiteral("start"), 0, reason);
}

bool VentilatorController::validateSettingEnvelope(const QString &parameter, int value, QString *reason) const
{
    const int prospectiveFio2 = parameter == QStringLiteral("fio2") ? value : m_fio2;
    const int prospectivePeep = parameter == QStringLiteral("peep") ? value : m_peep;
    const int prospectivePressureSupport = parameter == QStringLiteral("pressureSupport") ? value : m_pressureSupport;
    const int prospectiveInspiratoryTime = parameter == QStringLiteral("inspiratoryTime") ? value : m_inspiratoryTime;
    const int prospectiveRate = parameter == QStringLiteral("respiratoryRate") ? value : m_respiratoryRate;
    const int prospectiveTidalVolume = parameter == QStringLiteral("tidalVolume") ? value : m_tidalVolume;

    const double cycleSeconds = 60.0 / qMax(1, prospectiveRate);
    if (prospectiveInspiratoryTime >= cycleSeconds * 0.80) {
        if (reason)
            *reason = QStringLiteral("Rejected: inspiratory time is incompatible with respiratory rate");
        return false;
    }

    if (prospectivePeep + prospectivePressureSupport >= m_alarmHighPressure - 3) {
        if (reason)
            *reason = QStringLiteral("Rejected: PEEP + pressure support is too close to high pressure alarm");
        return false;
    }

    if (prospectiveTidalVolume < categoryMinVt() || prospectiveTidalVolume > categoryMaxVt()) {
        if (reason)
            *reason = QStringLiteral("Rejected: tidal volume outside %1 patient safe range (%2-%3 mL)")
                .arg(m_patientCategory).arg(categoryMinVt()).arg(categoryMaxVt());
        return false;
    }

    if (prospectiveRate < categoryMinRr() || prospectiveRate > categoryMaxRr()) {
        if (reason)
            *reason = QStringLiteral("Rejected: respiratory rate outside %1 patient safe range (%2-%3 1/min)")
                .arg(m_patientCategory).arg(categoryMinRr()).arg(categoryMaxRr());
        return false;
    }

    if (prospectiveFio2 > 80 && parameter == QStringLiteral("fio2")) {
        if (reason)
            *reason = QStringLiteral("Rejected: FiO2 above 80% requires high oxygen therapy confirmation workflow");
        return false;
    }

    return true;
}

int VentilatorController::categoryMinVt() const
{
    if (m_patientCategory == QStringLiteral("Neonatal"))
        return qMax(10, m_patientIbwKg * 4);
    if (m_patientCategory == QStringLiteral("Pediatric"))
        return qMax(30, m_patientIbwKg * 5);
    return qMax(150, m_patientIbwKg * 4);
}

int VentilatorController::categoryMaxVt() const
{
    if (m_patientCategory == QStringLiteral("Neonatal"))
        return qMin(80, m_patientIbwKg * 8);
    if (m_patientCategory == QStringLiteral("Pediatric"))
        return qMin(500, m_patientIbwKg * 10);
    return qMin(900, m_patientIbwKg * 10);
}

int VentilatorController::categoryMinRr() const
{
    if (m_patientCategory == QStringLiteral("Neonatal"))
        return 20;
    if (m_patientCategory == QStringLiteral("Pediatric"))
        return 10;
    return 4;
}

int VentilatorController::categoryMaxRr() const
{
    if (m_patientCategory == QStringLiteral("Neonatal"))
        return 80;
    if (m_patientCategory == QStringLiteral("Pediatric"))
        return 50;
    return 35;
}

void VentilatorController::setCommandMessage(const QString &message)
{
    if (m_lastCommandMessage == message)
        return;
    m_lastCommandMessage = message;
    emit commandMessageChanged();
}

void VentilatorController::setDegradedMode(bool degraded, const QString &state)
{
    const bool changed = m_degradedMode != degraded || m_backendState != state;
    m_degradedMode = degraded;
    m_backendState = state;
    if (degraded && m_running)
        stopVentilation();
    if (m_alarmController && degraded) {
        m_alarmController->raiseAlarm(QStringLiteral("Critical"),
                                      QStringLiteral("Backend"),
                                      QStringLiteral("Backend Disconnected"),
                                      state);
    }
    if (changed)
        emit backendStateChanged();
}

void VentilatorController::logSettingChange(const QString &parameter, const QVariant &oldValue, const QVariant &newValue)
{
    if (!m_database)
        return;
    m_database->logEvent(QStringLiteral("Setting"),
                         QStringLiteral("%1 changed from %2 to %3 by %4")
                             .arg(parameter, oldValue.toString(), newValue.toString(), m_operatorId),
                         QStringLiteral("Applied"));
}

void VentilatorController::checkBackendHeartbeat()
{
    if (!m_backendConnected)
        return;
    if (!m_running) {
        m_lastHardwareHeartbeatUtc = QDateTime::currentDateTimeUtc();
        return;
    }
    const qint64 ageMs = m_lastHardwareHeartbeatUtc.msecsTo(QDateTime::currentDateTimeUtc());
    if (ageMs > 5000) {
        m_backendConnected = false;
        setDegradedMode(true, QStringLiteral("No backend heartbeat for more than 5 seconds"));
        emit backendStateChanged();
    }
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
    // -----------------------------------------------------------------------
    // SIMULATION BOUNDARY
    // This method generates synthetic waveform and measurement data for the
    // demo UI. In production, replace this entire method body with a hardware
    // adapter that reads from the actual sensor bus. The QML contract (signals
    // and properties) remains unchanged.
    //
    // Hardware integration points:
    //   - Pressure (paw):  I2C/SPI pressure transducer (e.g. Honeywell ABPDANT)
    //   - Flow:            Pneumotachometer or thermal mass flow sensor
    //   - Volume:          Integrated flow signal (calculated in firmware)
    //   - CO2:             Mainstream/sidestream capnograph (e.g. Masimo ISA)
    //   - SpO2:            Pulse oximeter module (serial/CAN, e.g. Masimo SET)
    //   - Compliance:      Derived: Vt / (Pplat - PEEP)
    //   - Resistance:      Derived: (Ppeak - Pplat) / Flow
    //   - VTE, Ftotal:     Firmware-computed from flow integration
    //   - RCexp, ExpMinVol: Derived from VTE and Ftotal
    // -----------------------------------------------------------------------
    if (!m_running)
        return;

    recordHardwareHeartbeat();

    ++m_sampleIndex;
    const double dt = m_sampleTimer.interval() / 1000.0;
    const double rr = clampDouble(m_respiratoryRate, 6, 45);
    m_phase = std::fmod(m_phase + dt * rr / 60.0, 1.0);

    const double inspiratoryFraction = clampDouble(
        0.28 + m_inspiratoryTime * 0.05, 0.24, 0.46);
    const bool inspiration = m_phase < inspiratoryFraction;
    const double normalized = inspiration
        ? m_phase / inspiratoryFraction
        : (m_phase - inspiratoryFraction) / (1.0 - inspiratoryFraction);
    const double effort = std::sin(m_sampleIndex * 0.037) * 0.7
        + std::sin(m_sampleIndex * 0.011) * 0.4;
    const double pressureTarget = m_peep + m_pressureSupport
        + m_tidalVolume / 55.0;

    // ---------------------------------------------------------------
    // Mode-specific waveform generation
    // Each ventilation mode produces different pressure/flow patterns.
    // REPLACE: all of this with real sensor data in production.
    // ---------------------------------------------------------------
    double paw, flow, volume;
    const double flowPeak = m_tidalVolume / 7.0;

    if (m_mode == QStringLiteral("VCV")) {
        // Volume Control: square flow, rising pressure
        flow = inspiration
            ? flowPeak + effort * 2.0
            : -flowPeak * 0.6 * std::exp(-normalized * 3.0) + effort;
        paw = inspiration
            ? m_peep + (pressureTarget - m_peep) * normalized + effort
            : m_peep + effort * 0.3;
        volume = inspiration
            ? m_tidalVolume * normalized
            : m_tidalVolume * (1.0 - normalized);

    } else if (m_mode == QStringLiteral("PCV")) {
        // Pressure Control: square pressure, decelerating flow
        paw = inspiration
            ? pressureTarget + effort
            : m_peep + effort * 0.3;
        flow = inspiration
            ? flowPeak * std::exp(-normalized * 3.0) + effort * 2.0
            : -flowPeak * 0.5 * std::sin(M_PI * normalized) + effort;
        volume = inspiration
            ? m_tidalVolume * (1.0 - std::exp(-normalized * 4.0))
            : m_tidalVolume * std::exp(-normalized * 3.5);

    } else if (m_mode == QStringLiteral("CPAP")
               || m_mode == QStringLiteral("PSV")) {
        // CPAP/PSV: constant pressure, spontaneous patient flow
        double spontaneous = std::sin(m_phase * M_PI * 2.0);
        paw = m_peep + m_pressureSupport * 0.5
            + spontaneous * m_pressureSupport * 0.4 + effort * 0.5;
        flow = spontaneous * flowPeak * 0.6 + effort * 4.0;
        volume = (std::sin(m_phase * M_PI * 2.0 - M_PI / 2.0) + 1.0)
            * m_tidalVolume * 0.3;

    } else if (m_mode == QStringLiteral("SIMV")) {
        // SIMV: mandatory breaths with spontaneous between
        bool mandatoryBreath = (m_sampleIndex % 88) < 44;
        if (mandatoryBreath) {
            // Mandatory: like PCV
            paw = inspiration
                ? pressureTarget + effort
                : m_peep + effort * 0.3;
            flow = inspiration
                ? flowPeak * std::exp(-normalized * 2.5) + effort * 2.0
                : -flowPeak * 0.55 * std::sin(M_PI * normalized) + effort;
        } else {
            // Spontaneous: small pressure-supported breaths
            double spont = std::sin(m_phase * M_PI * 2.0);
            paw = m_peep + m_pressureSupport * 0.3
                + spont * 3.0 + effort * 0.4;
            flow = spont * flowPeak * 0.35 + effort * 3.0;
        }
        volume = inspiration
            ? m_tidalVolume * 0.7 * std::sin(normalized * M_PI / 2.0)
            : m_tidalVolume * 0.7 * std::exp(-normalized * 3.0);

    } else if (m_mode == QStringLiteral("BiPAP")) {
        // BiPAP: two pressure levels, patient-triggered
        double highP = m_peep + m_pressureSupport;
        paw = inspiration
            ? highP + effort * 0.5
            : m_peep + (highP - m_peep) * 0.15 + effort * 0.3;
        flow = inspiration
            ? flowPeak * 0.8 * (1.0 - normalized * 0.5) + effort * 2.5
            : -flowPeak * 0.6 * std::sin(M_PI * normalized) + effort;
        volume = inspiration
            ? m_tidalVolume * 0.85 * std::sin(normalized * M_PI / 2.0)
            : m_tidalVolume * 0.85 * std::exp(-normalized * 4.0);

    } else if (m_mode == QStringLiteral("PRVC")) {
        // PRVC: pressure-regulated volume control (adaptive pressure)
        double adaptedPressure = pressureTarget * 0.9
            + std::sin(m_sampleIndex * 0.005) * 2.0;
        paw = inspiration
            ? m_peep + (adaptedPressure - m_peep)
                * (1.0 - std::exp(-normalized * 8.0)) + effort
            : m_peep + effort * 0.25;
        flow = inspiration
            ? flowPeak * std::exp(-normalized * 2.0) + effort * 2.0
            : -flowPeak * 0.65 * std::sin(M_PI * normalized) + effort;
        volume = inspiration
            ? m_tidalVolume * (1.0 - std::exp(-normalized * 5.0))
            : m_tidalVolume * std::exp(-normalized * 4.0);

    } else {
        // Default (ASV and others): original exponential pattern
        paw = inspiration
            ? m_peep + (pressureTarget - m_peep)
                * (1.0 - std::exp(-normalized * 6.0)) + effort
            : m_peep + (pressureTarget - m_peep)
                * std::exp(-normalized * 9.0) + effort * 0.35;
        flow = inspiration
            ? flowPeak * (1.0 - normalized * 0.7) + effort * 3.0
            : -flowPeak * 0.72 * std::sin(M_PI * normalized)
                * std::exp(-normalized * 0.35) + effort * 2.0;
        volume = inspiration
            ? m_tidalVolume * std::sin(normalized * M_PI / 2.0)
            : m_tidalVolume * std::exp(-normalized * 4.4);
    }

    const double slow = std::sin(m_sampleIndex * 0.021);
    const double fio2Effect = (m_fio2 - 21.0) / 79.0;
    m_ppeak = qRound(clampDouble(pressureTarget + 6.0 + slow * 2.2, 8, 58)); // REPLACE: read from pressure sensor
    m_pplat = qRound(clampDouble(pressureTarget + 1.5 + slow, 6, 45)); // REPLACE: read from pressure sensor (plateau hold)
    m_pmean = qRound(clampDouble(m_peep + m_pressureSupport * 0.45 + slow, 4, 35)); // REPLACE: compute mean from pressure samples
    m_spo2 = qRound(clampDouble(92.0 + fio2Effect * 8.0 - qMax(0, m_peep - 18) * 0.15 + std::sin(m_sampleIndex * 0.013), 84, 100)); // REPLACE: read from pulse oximeter module
    m_etco2 = qRound(clampDouble(31.0 + std::sin(m_sampleIndex * 0.018) * 3.0 - (m_minuteVolume - 100.0) * 0.025, 18, 55)); // REPLACE: read from capnograph sensor
    m_compliance = qRound(clampDouble(m_tidalVolume / qMax(1.0, m_pplat - m_peep) + std::sin(m_sampleIndex * 0.017) * 4.0, 12, 95)); // REPLACE: derive from real Vt/(Pplat-PEEP)
    m_resistance = qRound(clampDouble(8.0 + m_trigger * 0.8 + std::sin(m_sampleIndex * 0.029) * 2.0, 3, 28)); // REPLACE: derive from real (Ppeak-Pplat)/Flow

    // Derived respiratory mechanics (per Behance design metrics)
    m_vte = qRound(clampDouble(m_tidalVolume * (0.92 + std::sin(m_sampleIndex * 0.023) * 0.06), 50, 900)); // REPLACE: read from flow integration firmware
    m_ftotal = qRound(clampDouble(rr + std::sin(m_sampleIndex * 0.019) * 1.5, 4, 60)); // REPLACE: count from breath detection firmware
    m_rcexp = clampDouble(m_compliance * m_resistance / 1000.0 + std::sin(m_sampleIndex * 0.031) * 0.08, 0.1, 2.5); // REPLACE: derive from real compliance * resistance
    m_rcexp = std::round(m_rcexp * 100.0) / 100.0;
    m_expMinVol = clampDouble(m_vte * m_ftotal / 1000.0, 0.5, 30.0); // REPLACE: derive from real VTE * Ftotal
    m_expMinVol = std::round(m_expMinVol * 10.0) / 10.0;
    const double co2 = inspiration // REPLACE: read from CO2 capnograph
        ? qMax(0.0, m_etco2 * std::exp(-normalized * 6.0) - 2.0)
        : m_etco2 * (1.0 - std::exp(-normalized * 8.0)) + std::sin(m_sampleIndex * 0.08);

    if (!m_frozen) {
        appendSample(m_pressureWaveform, paw); // BIND: pressure sensor stream
        appendSample(m_flowWaveform, flow); // BIND: flow sensor stream
        appendSample(m_volumeWaveform, volume); // BIND: volume integration stream (mL)
        appendSample(m_co2Waveform, co2); // BIND: CO2 sensor stream
    }

    // ---------------------------------------------------------------
    // Clinical decision support metrics (simulated)
    // REPLACE: derive from real sensor data in production
    // ---------------------------------------------------------------

    // Work of breathing (J/L): area under P-V curve approximation
    // Normal 0.3-0.7 J/L; elevated in restrictive/obstructive disease
    m_workOfBreathing = clampDouble(
        0.45 + (m_resistance - 12.0) * 0.03
        + (30.0 - m_compliance) * 0.008
        + std::sin(m_sampleIndex * 0.027) * 0.08,
        0.15, 2.5);
    m_workOfBreathing = std::round(m_workOfBreathing * 100.0) / 100.0;

    // Stress index: curvature of pressure-time curve during constant flow
    // 1.0 = linear (ideal), <1.0 = tidal recruitment, >1.0 = overdistension
    m_stressIndex = clampDouble(
        1.0 + (m_ppeak - 30.0) * 0.02
        + std::sin(m_sampleIndex * 0.019) * 0.05,
        0.6, 1.8);
    m_stressIndex = std::round(m_stressIndex * 100.0) / 100.0;

    // Dead space fraction (Vd/Vt): Bohr-Enghoff equation approximation
    // Normal 0.2-0.35; elevated in PE, ARDS, low cardiac output
    m_deadSpaceFraction = clampDouble(
        0.28 + (50.0 - m_etco2) * 0.004
        + std::sin(m_sampleIndex * 0.015) * 0.02,
        0.10, 0.80);
    m_deadSpaceFraction = std::round(m_deadSpaceFraction * 100.0) / 100.0;

    // O2 toxicity timer: count minutes with FiO2 > 60%
    // Risk of absorption atelectasis and pulmonary O2 toxicity
    if (m_fio2 > 60) {
        ++m_highFio2SampleCounter;
        // ~22 samples per second at 45ms interval, 60s = ~1333 samples
        if (m_highFio2SampleCounter >= 1333) {
            m_highFio2SampleCounter = 0;
            ++m_highFio2Minutes;
        }
    } else {
        m_highFio2SampleCounter = 0;
    }

    // Patient disconnect simulation: detect from near-zero waveform amplitude
    // REPLACE: in production, compare measured vs expected flow patterns
    m_patientDisconnected = (m_ppeak < 3.0 && m_running && m_sampleIndex > 100);

    // Circuit occlusion: abnormally high pressure with near-zero flow
    m_circuitOcclusion = (m_ppeak > 55.0 && std::abs(flow) < 2.0 && m_running);

    evaluateAlarms();
    saveSnapshotIfDue();
    emit measurementsChanged();
    if (!m_frozen)
        emit waveformChanged();
}

void VentilatorController::evaluateAlarms()
{
    // -----------------------------------------------------------------------
    // ALARM EVALUATION
    // In production, alarm thresholds should be validated against the device
    // specification limits. The alarm priority arbitration follows IEC 60601-1-8.
    // Hardware integration: connect alarm outputs to audible/visual indicators
    // via GPIO or dedicated alarm driver IC.
    // -----------------------------------------------------------------------
    if (!m_alarmController)
        return;

    // Throttle alarm row creation: only add a new row when the alarm state
    // transitions (not every 45ms sample tick).
    const bool wasPreviouslyActive = m_alarmController->active();

    // Patient disconnect: highest priority -- life-threatening
    if (m_patientDisconnected) {
        if (!wasPreviouslyActive || m_alarmController->headline() != QStringLiteral("Patient Disconnect")) {
            m_alarmController->addAlarm(
                QStringLiteral("Critical"), QStringLiteral("Circuit"),
                QStringLiteral("No airway pressure detected -- check patient connection"),
                QStringLiteral("Active"));
        }
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Critical"));
        m_alarmController->setHeadline(QStringLiteral("Patient Disconnect"));
        m_alarmController->setDetail(QStringLiteral("Check circuit and patient"));
        return;
    }

    // Circuit occlusion: high pressure with no flow
    if (m_circuitOcclusion) {
        if (!wasPreviouslyActive || m_alarmController->headline() != QStringLiteral("Circuit Occlusion")) {
            m_alarmController->addAlarm(
                QStringLiteral("Critical"), QStringLiteral("Circuit"),
                QStringLiteral("High pressure with no flow -- check for obstruction"),
                QStringLiteral("Active"));
        }
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Critical"));
        m_alarmController->setHeadline(QStringLiteral("Circuit Occlusion"));
        m_alarmController->setDetail(QStringLiteral("Check tubing and filters"));
        return;
    }

    if (m_ppeak > m_alarmHighPressure) {
        if (!wasPreviouslyActive || m_alarmController->headline() != QStringLiteral("High Pressure")) {
            m_alarmController->addAlarm(
                QStringLiteral("Critical"), QStringLiteral("Pressure"),
                QStringLiteral("Paw above limit — Ppeak ") + QString::number(qRound(m_ppeak)) + QStringLiteral(" cmH2O"),
                QStringLiteral("Active"));
        }
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Critical"));
        m_alarmController->setHeadline(QStringLiteral("High Pressure"));
        m_alarmController->setDetail(QStringLiteral("Paw above limit"));
        return;
    }

    if (m_minuteVolume > m_alarmHighMv * 10) {
        if (!wasPreviouslyActive || m_alarmController->headline() != QStringLiteral("High Minute Volume")) {
            m_alarmController->addAlarm(
                QStringLiteral("Critical"), QStringLiteral("Volume"),
                QStringLiteral("Minute volume ") + QString::number(m_minuteVolume) + QStringLiteral("% exceeds limit"),
                QStringLiteral("Active"));
        }
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Critical"));
        m_alarmController->setHeadline(QStringLiteral("High Minute Volume"));
        m_alarmController->setDetail(QStringLiteral("CT Low"));
        return;
    }

    if (m_spo2 < m_alarmLowSpo2 && m_spo2 > 0) {
        if (!wasPreviouslyActive || m_alarmController->headline() != QStringLiteral("Low SpO2")) {
            m_alarmController->addAlarm(
                QStringLiteral("Warning"), QStringLiteral("Oximetry"),
                QStringLiteral("SpO2 ") + QString::number(qRound(m_spo2)) + QStringLiteral("% below threshold"),
                QStringLiteral("Active"));
        }
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Warning"));
        m_alarmController->setHeadline(QStringLiteral("Low SpO2"));
        m_alarmController->setDetail(QStringLiteral("Oxygen saturation below 90%"));
        return;
    }

    if (m_etco2 > 50) {
        if (!wasPreviouslyActive || m_alarmController->headline() != QStringLiteral("High EtCO2")) {
            m_alarmController->addAlarm(
                QStringLiteral("Warning"), QStringLiteral("Capnography"),
                QStringLiteral("EtCO2 ") + QString::number(qRound(m_etco2)) + QStringLiteral(" mmHg above limit"),
                QStringLiteral("Active"));
        }
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Warning"));
        m_alarmController->setHeadline(QStringLiteral("High EtCO2"));
        m_alarmController->setDetail(QStringLiteral("End-tidal CO2 elevated"));
        return;
    }

    // O2 toxicity warning: prolonged high FiO2 exposure
    if (m_highFio2Minutes > 120 && m_fio2 > 60) {
        if (!wasPreviouslyActive || m_alarmController->headline() != QStringLiteral("O2 Toxicity Risk")) {
            m_alarmController->addAlarm(
                QStringLiteral("Warning"), QStringLiteral("Oxygen"),
                QStringLiteral("FiO2 >60% for ") + QString::number(m_highFio2Minutes)
                    + QStringLiteral(" min -- consider weaning"),
                QStringLiteral("Active"));
        }
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Warning"));
        m_alarmController->setHeadline(QStringLiteral("O2 Toxicity Risk"));
        m_alarmController->setDetail(QStringLiteral("Prolonged high FiO2 exposure"));
        return;
    }

    // High driving pressure warning (lung protection)
    if (drivingPressure() > 15.0) {
        if (!wasPreviouslyActive || m_alarmController->headline() != QStringLiteral("High Driving Pressure")) {
            m_alarmController->addAlarm(
                QStringLiteral("Warning"), QStringLiteral("Pressure"),
                QStringLiteral("Driving pressure ") + QString::number(qRound(drivingPressure()))
                    + QStringLiteral(" cmH2O -- target <15"),
                QStringLiteral("Active"));
        }
        m_alarmController->setActive(true);
        m_alarmController->setPriority(QStringLiteral("Warning"));
        m_alarmController->setHeadline(QStringLiteral("High Driving Pressure"));
        m_alarmController->setDetail(QStringLiteral("Lung injury risk -- reduce Vt or increase PEEP"));
        return;
    }

    // Clear alarm state when all conditions are normal.
    if (wasPreviouslyActive) {
        m_alarmController->addAlarm(
            QStringLiteral("Info"), QStringLiteral("System"),
            QStringLiteral("All parameters within normal limits"),
            QStringLiteral("Resolved"));
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
