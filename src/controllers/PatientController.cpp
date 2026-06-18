#include "PatientController.h"
#include "../core/DatabaseManager.h"

#include <QtMath>
#include <QDate>

PatientController::PatientController(DatabaseManager *database, QObject *parent)
    : QObject(parent)
    , m_database(database)
{
    m_admitDate = QDate::currentDate().toString(Qt::ISODate);
    loadProfile();
}

QString PatientController::category() const { return m_category; }
QString PatientController::profile() const { return m_profile; }
QString PatientController::gender() const { return m_gender; }
int PatientController::age() const { return m_age; }
int PatientController::height() const { return m_height; }
int PatientController::weight() const { return m_weight; }
QString PatientController::patientId() const { return m_patientId; }
QString PatientController::bedNumber() const { return m_bedNumber; }
QString PatientController::physician() const { return m_physician; }
QString PatientController::admitDate() const { return m_admitDate; }

int PatientController::ibw() const
{
    if (m_category == QStringLiteral("Neonatal"))
        return qBound(1, m_weight, 8);
    if (m_category == QStringLiteral("Pediatric"))
        return qBound(3, m_weight, 60);

    // CLINICAL: Adult ideal body weight calculation uses Devine formula (1974).
    // Verify with clinical SME before production deployment.
    const double base = m_gender == QStringLiteral("Male") ? 50.0 : 45.5;
    return qBound(20, qRound(base + 0.91 * (m_height - 152.4)), 160);
}

int PatientController::recommendedVt() const
{
    // CLINICAL: Tidal volume recommendation uses 6 mL/kg IBW (ARDSNet).
    // Adjust range per institutional protocol (6-8 mL/kg typical).
    if (m_category == QStringLiteral("Neonatal"))
        return qBound(20, m_weight * 6, 60);
    if (m_category == QStringLiteral("Pediatric"))
        return qBound(30, ibw() * 7, 450);
    return qBound(150, ibw() * 6, 900);
}

int PatientController::recommendedRate() const
{
    if (m_category == QStringLiteral("Neonatal"))
        return 36;
    if (m_category == QStringLiteral("Pediatric"))
        return 24;
    return 16;
}

void PatientController::logPatientChange(const QString &field, const QVariant &oldValue, const QVariant &newValue)
{
    if (!m_database)
        return;
    m_database->logEvent(QStringLiteral("Patient"),
                         QStringLiteral("%1 changed from %2 to %3")
                             .arg(field, oldValue.toString(), newValue.toString()),
                         QStringLiteral("Updated"));
}

void PatientController::setCategory(const QString &value)
{
    if (m_category == value)
        return;
    const QString oldValue = m_category;
    m_category = value;
    logPatientChange(QStringLiteral("Category"), oldValue, m_category);
    emit patientChanged();
}

void PatientController::setProfile(const QString &value)
{
    if (m_profile == value)
        return;
    const QString oldValue = m_profile;
    m_profile = value;
    logPatientChange(QStringLiteral("Profile"), oldValue, m_profile);
    emit patientChanged();
}

void PatientController::setGender(const QString &value)
{
    if (m_gender == value)
        return;
    const QString oldValue = m_gender;
    m_gender = value;
    logPatientChange(QStringLiteral("Gender"), oldValue, m_gender);
    emit patientChanged();
}

void PatientController::setAge(int value)
{
    value = qBound(0, value, 120);
    if (m_age == value)
        return;
    const int oldValue = m_age;
    m_age = value;
    logPatientChange(QStringLiteral("Age"), oldValue, m_age);
    emit patientChanged();
}

void PatientController::setHeight(int value)
{
    value = qBound(40, value, 230);
    if (m_height == value)
        return;
    const int oldValue = m_height;
    m_height = value;
    logPatientChange(QStringLiteral("Height cm"), oldValue, m_height);
    emit patientChanged();
}

void PatientController::setWeight(int value)
{
    value = qBound(1, value, 260);
    if (m_weight == value)
        return;
    const int oldValue = m_weight;
    m_weight = value;
    logPatientChange(QStringLiteral("Weight kg"), oldValue, m_weight);
    emit patientChanged();
}

void PatientController::setPatientId(const QString &value)
{
    if (m_patientId == value) return;
    const QString oldValue = m_patientId;
    m_patientId = value;
    logPatientChange(QStringLiteral("Patient ID"), oldValue, m_patientId);
    emit patientChanged();
}

void PatientController::setBedNumber(const QString &value)
{
    if (m_bedNumber == value) return;
    const QString oldValue = m_bedNumber;
    m_bedNumber = value;
    logPatientChange(QStringLiteral("Bed number"), oldValue, m_bedNumber);
    emit patientChanged();
}

void PatientController::setPhysician(const QString &value)
{
    if (m_physician == value) return;
    const QString oldValue = m_physician;
    m_physician = value;
    logPatientChange(QStringLiteral("Physician"), oldValue, m_physician);
    emit patientChanged();
}

void PatientController::setAdmitDate(const QString &value)
{
    if (m_admitDate == value) return;
    const QString oldValue = m_admitDate;
    m_admitDate = value;
    logPatientChange(QStringLiteral("Admit date"), oldValue, m_admitDate);
    emit patientChanged();
}

void PatientController::saveProfile()
{
    if (!m_database)
        return;

    m_database->savePatientProfile({
        { QStringLiteral("category"), m_category },
        { QStringLiteral("gender"),   m_gender },
        { QStringLiteral("age"),      m_age },
        { QStringLiteral("height"),   m_height },
        { QStringLiteral("weight"),   m_weight },
        { QStringLiteral("ibw"),      ibw() }
    });
    m_database->saveClinicalState(QStringLiteral("patientId"), m_patientId);
    m_database->saveClinicalState(QStringLiteral("bedNumber"), m_bedNumber);
    m_database->saveClinicalState(QStringLiteral("physician"), m_physician);
    m_database->saveClinicalState(QStringLiteral("admitDate"), m_admitDate);
    m_database->logEvent(QStringLiteral("Patient"),
                         QStringLiteral("Patient profile saved"),
                         QStringLiteral("Saved"));
}

void PatientController::loadProfile()
{
    if (!m_database)
        return;

    const QVariantMap profile = m_database->loadLastPatientProfile();
    if (!profile.isEmpty()) {
        m_category = profile.value(QStringLiteral("category"), m_category).toString();
        m_gender   = profile.value(QStringLiteral("gender"), m_gender).toString();
        m_age      = profile.value(QStringLiteral("age"), m_age).toInt();
        m_height   = profile.value(QStringLiteral("height"), m_height).toInt();
        m_weight   = profile.value(QStringLiteral("weight"), m_weight).toInt();
    }

    const QVariantMap state = m_database->loadClinicalState();
    m_patientId = state.value(QStringLiteral("patientId"), m_patientId).toString();
    m_bedNumber = state.value(QStringLiteral("bedNumber"), m_bedNumber).toString();
    m_physician = state.value(QStringLiteral("physician"), m_physician).toString();
    m_admitDate = state.value(QStringLiteral("admitDate"), m_admitDate).toString();
    emit patientChanged();
}
