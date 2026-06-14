#pragma once

#include <QObject>
#include <QVariantMap>

class DatabaseManager;

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
    explicit PatientController(DatabaseManager *database = nullptr,
                               QObject *parent = nullptr);

    /** @brief Saves the current patient profile to the database. */
    Q_INVOKABLE void saveProfile();

    /** @brief Loads the most recent patient profile from the database. */
    Q_INVOKABLE void loadProfile();

    /** @return Patient category (e.g. "Adult", "Pediatric"). */
    QString category() const;
    /** @return Patient profile name or label. */
    QString profile() const;
    /** @return Patient gender (e.g. "Male", "Female"). */
    QString gender() const;
    /** @return Patient age in years. */
    int age() const;
    /** @return Patient height in centimeters. */
    int height() const;
    /** @return Patient weight in kilograms. */
    int weight() const;
    /** @return Ideal body weight in kilograms. */
    int ibw() const;
    /** @return Recommended tidal volume in mL based on IBW. */
    int recommendedVt() const;
    /** @return Recommended respiratory rate in breaths per minute. */
    int recommendedRate() const;

public slots:
    /** @param value Patient category to set (e.g. "Adult", "Pediatric"). */
    void setCategory(const QString &value);
    /** @param value Patient profile name or label. */
    void setProfile(const QString &value);
    /** @param value Patient gender (e.g. "Male", "Female"). */
    void setGender(const QString &value);
    /** @param value Patient age in years. */
    void setAge(int value);
    /** @param value Patient height in centimeters. */
    void setHeight(int value);
    /** @param value Patient weight in kilograms. */
    void setWeight(int value);

signals:
    void patientChanged();

private:
    DatabaseManager *m_database = nullptr;
    QString m_category = QStringLiteral("Adult");
    QString m_profile = QStringLiteral("Recent patient");
    QString m_gender = QStringLiteral("Male");
    int m_age = 54;
    int m_height = 178;
    int m_weight = 76;
};
