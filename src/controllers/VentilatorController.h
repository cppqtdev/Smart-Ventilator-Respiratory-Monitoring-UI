#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>

class AlarmController;
class DatabaseManager;

/**
 * @brief Simulates a real ventilator hardware data stream for the demo UI.
 *
 * VentilatorController exposes setpoints, measurements, rolling waveform
 * buffers, and operator actions to QML. The class intentionally mirrors a
 * future hardware integration boundary: in production, the simulation loop can
 * be replaced with a serial/CAN/Ethernet device adapter while keeping the QML
 * contract stable.
 */
class VentilatorController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(bool frozen READ frozen NOTIFY frozenChanged)
    Q_PROPERTY(QString mode READ mode WRITE setMode NOTIFY settingsChanged)
    Q_PROPERTY(int fio2 READ fio2 WRITE setFio2 NOTIFY settingsChanged)
    Q_PROPERTY(int peep READ peep WRITE setPeep NOTIFY settingsChanged)
    Q_PROPERTY(int pressureSupport READ pressureSupport WRITE setPressureSupport NOTIFY settingsChanged)
    Q_PROPERTY(int inspiratoryTime READ inspiratoryTime WRITE setInspiratoryTime NOTIFY settingsChanged)
    Q_PROPERTY(int respiratoryRate READ respiratoryRate WRITE setRespiratoryRate NOTIFY settingsChanged)
    Q_PROPERTY(int trigger READ trigger WRITE setTrigger NOTIFY settingsChanged)
    Q_PROPERTY(int minuteVolume READ minuteVolume WRITE setMinuteVolume NOTIFY settingsChanged)
    Q_PROPERTY(int tidalVolume READ tidalVolume WRITE setTidalVolume NOTIFY settingsChanged)
    Q_PROPERTY(double ppeak READ ppeak NOTIFY measurementsChanged)
    Q_PROPERTY(double pplat READ pplat NOTIFY measurementsChanged)
    Q_PROPERTY(double pmean READ pmean NOTIFY measurementsChanged)
    Q_PROPERTY(double spo2 READ spo2 NOTIFY measurementsChanged)
    Q_PROPERTY(double etco2 READ etco2 NOTIFY measurementsChanged)
    Q_PROPERTY(double compliance READ compliance NOTIFY measurementsChanged)
    Q_PROPERTY(double resistance READ resistance NOTIFY measurementsChanged)
    Q_PROPERTY(double vte READ vte NOTIFY measurementsChanged)
    Q_PROPERTY(double ftotal READ ftotal NOTIFY measurementsChanged)
    Q_PROPERTY(double rcexp READ rcexp NOTIFY measurementsChanged)
    Q_PROPERTY(double expMinVol READ expMinVol NOTIFY measurementsChanged)
    Q_PROPERTY(QString ventilationTime READ ventilationTime NOTIFY measurementsChanged)
    Q_PROPERTY(int alarmHighPressure READ alarmHighPressure WRITE setAlarmHighPressure NOTIFY settingsChanged)
    Q_PROPERTY(int alarmLowPressure READ alarmLowPressure WRITE setAlarmLowPressure NOTIFY settingsChanged)
    Q_PROPERTY(int alarmApneaTime READ alarmApneaTime WRITE setAlarmApneaTime NOTIFY settingsChanged)
    Q_PROPERTY(int alarmLowVt READ alarmLowVt WRITE setAlarmLowVt NOTIFY settingsChanged)
    Q_PROPERTY(int alarmHighMv READ alarmHighMv WRITE setAlarmHighMv NOTIFY settingsChanged)
    Q_PROPERTY(int alarmLowSpo2 READ alarmLowSpo2 WRITE setAlarmLowSpo2 NOTIFY settingsChanged)
    Q_PROPERTY(bool apneaBackupEnabled READ apneaBackupEnabled WRITE setApneaBackupEnabled NOTIFY settingsChanged)
    Q_PROPERTY(int ventilationSeconds READ ventilationSeconds NOTIFY measurementsChanged)
    Q_PROPERTY(QVariantList pressureWaveform READ pressureWaveform NOTIFY waveformChanged)
    Q_PROPERTY(QVariantList flowWaveform READ flowWaveform NOTIFY waveformChanged)
    Q_PROPERTY(QVariantList volumeWaveform READ volumeWaveform NOTIFY waveformChanged)
    Q_PROPERTY(QVariantList co2Waveform READ co2Waveform NOTIFY waveformChanged)

public:
    /**
     * @param database Pointer to the application database manager.
     * @param alarmController Pointer to the alarm controller for threshold evaluation.
     * @param parent Optional parent QObject for ownership.
     */
    explicit VentilatorController(DatabaseManager *database,
                                  AlarmController *alarmController,
                                  QObject *parent = nullptr);

    /** @return True if the ventilator simulation is actively running. */
    bool running() const;
    /** @return True if waveform display is frozen. */
    bool frozen() const;
    /** @return Current ventilation mode identifier (e.g. "ASV", "PCV"). */
    QString mode() const;
    /** @return Fraction of inspired oxygen setpoint in percent. */
    int fio2() const;
    /** @return Positive end-expiratory pressure setpoint in cmH2O. */
    int peep() const;
    /** @return Pressure support setpoint in cmH2O. */
    int pressureSupport() const;
    /** @return Inspiratory time setpoint in seconds. */
    int inspiratoryTime() const;
    /** @return Respiratory rate setpoint in breaths per minute. */
    int respiratoryRate() const;
    /** @return Flow trigger sensitivity setpoint in L/min. */
    int trigger() const;
    /** @return Minute volume setpoint in mL/min. */
    int minuteVolume() const;
    /** @return Tidal volume setpoint in mL. */
    int tidalVolume() const;
    /** @return Measured peak airway pressure in cmH2O. */
    double ppeak() const;
    /** @return Measured plateau airway pressure in cmH2O. */
    double pplat() const;
    /** @return Measured mean airway pressure in cmH2O. */
    double pmean() const;
    /** @return Measured peripheral oxygen saturation in percent. */
    double spo2() const;
    /** @return Measured end-tidal CO2 in mmHg. */
    double etco2() const;
    /** @return Measured lung compliance in mL/cmH2O. */
    double compliance() const;
    /** @return Measured airway resistance in cmH2O/(L/s). */
    double resistance() const;
    /** @return Measured expired tidal volume in mL. */
    double vte() const;
    /** @return Total respiratory frequency in breaths/min. */
    double ftotal() const;
    /** @return Expiratory time constant in seconds. */
    double rcexp() const;
    /** @return Measured expired minute volume in L/min. */
    double expMinVol() const;
    /** @return Formatted ventilation elapsed time as HH:MM:SS. */
    QString ventilationTime() const;
    /** @return Ventilation elapsed time in seconds. */
    int ventilationSeconds() const;

    int alarmHighPressure() const;
    int alarmLowPressure() const;
    int alarmApneaTime() const;
    int alarmLowVt() const;
    int alarmHighMv() const;
    int alarmLowSpo2() const;
    bool apneaBackupEnabled() const;

    /** @return Rolling pressure waveform sample buffer. */
    QVariantList pressureWaveform() const;
    /** @return Rolling flow waveform sample buffer. */
    QVariantList flowWaveform() const;
    /** @return Rolling volume waveform sample buffer. */
    QVariantList volumeWaveform() const;
    /** @return Rolling CO2 waveform sample buffer. */
    QVariantList co2Waveform() const;

    /** @brief Starts the ventilator simulation loop. */
    Q_INVOKABLE void startVentilation();
    /** @brief Stops the ventilator simulation loop. */
    Q_INVOKABLE void stopVentilation();
    /** @brief Toggles waveform freeze on or off. */
    Q_INVOKABLE void toggleFreeze();
    /** @brief Runs a simulated sensor calibration sequence. */
    Q_INVOKABLE void runCalibration();

public slots:
    /** @param value Ventilation mode identifier to apply. */
    void setMode(const QString &value);
    /** @param value FiO2 setpoint in percent. */
    void setFio2(int value);
    /** @param value PEEP setpoint in cmH2O. */
    void setPeep(int value);
    /** @param value Pressure support setpoint in cmH2O. */
    void setPressureSupport(int value);
    /** @param value Inspiratory time setpoint in seconds. */
    void setInspiratoryTime(int value);
    /** @param value Respiratory rate setpoint in breaths per minute. */
    void setRespiratoryRate(int value);
    /** @param value Flow trigger sensitivity in L/min. */
    void setTrigger(int value);
    /** @param value Minute volume setpoint in mL/min. */
    void setMinuteVolume(int value);
    /** @param value Tidal volume setpoint in mL. */
    void setTidalVolume(int value);

    void setAlarmHighPressure(int value);
    void setAlarmLowPressure(int value);
    void setAlarmApneaTime(int value);
    void setAlarmLowVt(int value);
    void setAlarmHighMv(int value);
    void setAlarmLowSpo2(int value);
    void setApneaBackupEnabled(bool value);

signals:
    void runningChanged();
    void frozenChanged();
    void settingsChanged();
    void measurementsChanged();
    void waveformChanged();

private slots:
    void updateSimulation();

private:
    void appendSample(QVariantList &buffer, double value);
    void evaluateAlarms();
    void saveSnapshotIfDue();
    QVariantMap snapshot() const;

    DatabaseManager *m_database = nullptr;
    AlarmController *m_alarmController = nullptr;
    QTimer m_sampleTimer;
    bool m_running = false;
    bool m_frozen = false;
    QString m_mode = QStringLiteral("ASV");
    int m_fio2 = 60;
    int m_peep = 15;
    int m_pressureSupport = 12;
    int m_inspiratoryTime = 1;
    int m_respiratoryRate = 20;
    int m_trigger = 3;
    int m_minuteVolume = 110;
    int m_tidalVolume = 420;
    double m_ppeak = 0;
    double m_pplat = 0;
    double m_pmean = 0;
    double m_spo2 = 0;
    double m_etco2 = 0;
    double m_compliance = 0;
    double m_resistance = 0;
    double m_vte = 0;
    double m_ftotal = 0;
    double m_rcexp = 0;
    double m_expMinVol = 0;
    int m_alarmHighPressure = 40;
    int m_alarmLowPressure = 5;
    int m_alarmApneaTime = 20;
    int m_alarmLowVt = 300;
    int m_alarmHighMv = 12;
    int m_alarmLowSpo2 = 90;
    bool m_apneaBackupEnabled = true;
    double m_phase = 0;
    int m_sampleIndex = 0;
    int m_snapshotCounter = 0;
    int m_ventilationSeconds = 0;
    QTimer m_ventilationTimer;
    QVariantList m_pressureWaveform;
    QVariantList m_flowWaveform;
    QVariantList m_volumeWaveform;
    QVariantList m_co2Waveform;
};
