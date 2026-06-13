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
    Q_PROPERTY(QVariantList pressureWaveform READ pressureWaveform NOTIFY waveformChanged)
    Q_PROPERTY(QVariantList flowWaveform READ flowWaveform NOTIFY waveformChanged)
    Q_PROPERTY(QVariantList volumeWaveform READ volumeWaveform NOTIFY waveformChanged)
    Q_PROPERTY(QVariantList co2Waveform READ co2Waveform NOTIFY waveformChanged)

public:
    explicit VentilatorController(DatabaseManager *database,
                                  AlarmController *alarmController,
                                  QObject *parent = nullptr);

    bool running() const;
    bool frozen() const;
    QString mode() const;
    int fio2() const;
    int peep() const;
    int pressureSupport() const;
    int inspiratoryTime() const;
    int respiratoryRate() const;
    int trigger() const;
    int minuteVolume() const;
    int tidalVolume() const;
    double ppeak() const;
    double pplat() const;
    double pmean() const;
    double spo2() const;
    double etco2() const;
    double compliance() const;
    double resistance() const;
    QVariantList pressureWaveform() const;
    QVariantList flowWaveform() const;
    QVariantList volumeWaveform() const;
    QVariantList co2Waveform() const;

    Q_INVOKABLE void startVentilation();
    Q_INVOKABLE void stopVentilation();
    Q_INVOKABLE void toggleFreeze();
    Q_INVOKABLE void runCalibration();

public slots:
    void setMode(const QString &value);
    void setFio2(int value);
    void setPeep(int value);
    void setPressureSupport(int value);
    void setInspiratoryTime(int value);
    void setRespiratoryRate(int value);
    void setTrigger(int value);
    void setMinuteVolume(int value);
    void setTidalVolume(int value);

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
    double m_phase = 0;
    int m_sampleIndex = 0;
    int m_snapshotCounter = 0;
    QVariantList m_pressureWaveform;
    QVariantList m_flowWaveform;
    QVariantList m_volumeWaveform;
    QVariantList m_co2Waveform;
};
