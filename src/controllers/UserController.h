#pragma once

#include <QObject>
#include <QDateTime>
#include <QHash>
#include <QVariantList>
#include <QVariantMap>

class DatabaseManager;

/**
 * @brief Manages user accounts, authentication, and role-based access control.
 *
 * UserController provides CRUD operations for user accounts stored in SQLite.
 * Passwords are stored as salted iterative SHA-256 PIN hashes. Roles control screen access:
 *   - "Admin"    : Full access, can manage all users
 *   - "Doctor"   : Clinical access, can modify ventilator settings
 *   - "Nurse"    : Monitoring access, can acknowledge alarms
 *   - "Service"  : Technical access, system diagnostics and calibration
 *
 * PRODUCTION: Prefer a certified password KDF such as Argon2id/scrypt from a
 * validated crypto module when the final platform policy allows it.
 */
class UserController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentUser READ currentUser NOTIFY sessionChanged)
    Q_PROPERTY(QString currentRole READ currentRole NOTIFY sessionChanged)
    Q_PROPERTY(bool loggedIn READ loggedIn NOTIFY sessionChanged)
    Q_PROPERTY(int lockTimeoutSeconds READ lockTimeoutSeconds
               WRITE setLockTimeoutSeconds NOTIFY lockTimeoutChanged)

public:
    explicit UserController(DatabaseManager *database, QObject *parent = nullptr);

    /** @return Username of the currently logged-in operator. */
    QString currentUser() const;
    /** @return Role of the currently logged-in operator. */
    QString currentRole() const;
    /** @return True if an operator is currently authenticated. */
    bool loggedIn() const;
    /** @return Screen lock inactivity timeout in seconds. */
    int lockTimeoutSeconds() const;

    /**
     * @brief Authenticates a user with username and PIN.
     * @param username  Account username.
     * @param pin  4-digit PIN code.
     * @return True if authentication succeeded.
     */
    Q_INVOKABLE bool login(const QString &username, const QString &pin);

    /** @brief Ends the current operator session. */
    Q_INVOKABLE void logout();

    /**
     * @brief Creates a new user account.
     * @param username  Unique username (3-20 characters).
     * @param pin  4-digit PIN code.
     * @param role  User role ("Admin", "Doctor", "Nurse", "Service").
     * @param fullName  Display name for the user.
     * @return True if the account was created successfully.
     */
    Q_INVOKABLE bool createUser(const QString &username,
                                 const QString &pin,
                                 const QString &role,
                                 const QString &fullName);

    /**
     * @brief Deletes a user account. Only Admin role can delete users.
     * @param username  Account to delete.
     * @return True if the account was deleted successfully.
     */
    Q_INVOKABLE bool deleteUser(const QString &username);

    /**
     * @brief Changes the PIN for a user account.
     * @param username  Account to update. Admin can change any user's PIN.
     * @param newPin  New 4-digit PIN code.
     * @return True if the PIN was changed successfully.
     */
    Q_INVOKABLE bool changePin(const QString &username,
                                const QString &newPin);

    /**
     * @brief Updates a user's role and display name. Admin only.
     * @param username  Account to update.
     * @param role  New role.
     * @param fullName  New display name.
     * @return True if the profile was updated successfully.
     */
    Q_INVOKABLE bool updateUser(const QString &username,
                                 const QString &role,
                                 const QString &fullName);

    /**
     * @brief Returns all user accounts as a list of maps.
     * @return List of {username, role, fullName, createdAt} maps.
     */
    Q_INVOKABLE QVariantList listUsers() const;

    /**
     * @brief Checks if the current user has a specific role or higher.
     * @param requiredRole  Minimum role required ("Nurse", "Doctor", "Admin").
     * @return True if the current user's role meets or exceeds the requirement.
     */
    Q_INVOKABLE bool hasAccess(const QString &requiredRole) const;

    /** @param seconds  Screen lock inactivity timeout. */
    Q_INVOKABLE void setLockTimeoutSeconds(int seconds);

signals:
    void sessionChanged();
    void lockTimeoutChanged();
    void loginFailed(const QString &reason);
    void userListChanged();

private:
    static QString createSalt();
    static QString hashPin(const QString &pin, const QString &salt);
    static bool pinFormatValid(const QString &pin);
    static bool roleValid(const QString &role);
    static int roleLevel(const QString &role);
    void provisionInitialAdminFromEnvironment();
    void persistFailedLogin(const QString &username, int failures, const QDateTime &lockedUntilUtc);
    void clearFailedLogin(const QString &username);

    DatabaseManager *m_database = nullptr;
    QString m_currentUser;
    QString m_currentRole;
    int m_lockTimeoutSeconds = 300;
    QHash<QString, int> m_failedAttempts;
    QHash<QString, QDateTime> m_lockedUntilUtc;
};
