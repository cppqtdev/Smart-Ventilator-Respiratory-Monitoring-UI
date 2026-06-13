#include "PatientController.h"

#include <QtMath>

PatientController::PatientController(QObject *parent)
    : QObject(parent)
{
}

QString PatientController::category() const { return m_category; }
QString PatientController::profile() const { return m_profile; }
QString PatientController::gender() const { return m_gender; }
int PatientController::age() const { return m_age; }
int PatientController::height() const { return m_height; }
int PatientController::weight() const { return m_weight; }

int PatientController::ibw() const
{
    const double base = m_gender == QStringLiteral("Male") ? 50.0 : 45.5;
    return qRound(base + 0.91 * (m_height - 152.4));
}

int PatientController::recommendedVt() const
{
    return qMax(20, ibw() * 6);
}

int PatientController::recommendedRate() const
{
    if (m_category == QStringLiteral("Neonatal"))
        return 36;
    if (m_category == QStringLiteral("Pediatric"))
        return 24;
    return 16;
}

void PatientController::setCategory(const QString &value)
{
    if (m_category == value)
        return;
    m_category = value;
    emit patientChanged();
}

void PatientController::setProfile(const QString &value)
{
    if (m_profile == value)
        return;
    m_profile = value;
    emit patientChanged();
}

void PatientController::setGender(const QString &value)
{
    if (m_gender == value)
        return;
    m_gender = value;
    emit patientChanged();
}

void PatientController::setAge(int value)
{
    value = qBound(0, value, 120);
    if (m_age == value)
        return;
    m_age = value;
    emit patientChanged();
}

void PatientController::setHeight(int value)
{
    value = qBound(40, value, 230);
    if (m_height == value)
        return;
    m_height = value;
    emit patientChanged();
}

void PatientController::setWeight(int value)
{
    value = qBound(1, value, 260);
    if (m_weight == value)
        return;
    m_weight = value;
    emit patientChanged();
}
