#pragma once

#include <QObject>

/**
 * @brief Stores editable patient demographics and derived clinical suggestions.
 *
 * PatientController exposes patient category, gender, age, height, weight, IBW,
 * recommended tidal volume, and recommended respiratory rate to QML. Values are
 * intentionally simple for demo use and should be validated by clinical SMEs
 * before production deployment.
 */
class PatientController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString category READ category WRITE setCategory NOTIFY patientChanged)
    Q_PROPERTY(QString profile READ profile WRITE setProfile NOTIFY patientChanged)
    Q_PROPERTY(QString gender READ gender WRITE setGender NOTIFY patientChanged)
    Q_PROPERTY(int age READ age WRITE setAge NOTIFY patientChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY patientChanged)
    Q_PROPERTY(int weight READ weight WRITE setWeight NOTIFY patientChanged)
    Q_PROPERTY(int ibw READ ibw NOTIFY patientChanged)
    Q_PROPERTY(int recommendedVt READ recommendedVt NOTIFY patientChanged)
    Q_PROPERTY(int recommendedRate READ recommendedRate NOTIFY patientChanged)

public:
    explicit PatientController(QObject *parent = nullptr);

    QString category() const;
    QString profile() const;
    QString gender() const;
    int age() const;
    int height() const;
    int weight() const;
    int ibw() const;
    int recommendedVt() const;
    int recommendedRate() const;

public slots:
    void setCategory(const QString &value);
    void setProfile(const QString &value);
    void setGender(const QString &value);
    void setAge(int value);
    void setHeight(int value);
    void setWeight(int value);

signals:
    void patientChanged();

private:
    QString m_category = QStringLiteral("Adult");
    QString m_profile = QStringLiteral("Recent patient");
    QString m_gender = QStringLiteral("Male");
    int m_age = 54;
    int m_height = 178;
    int m_weight = 76;
};
