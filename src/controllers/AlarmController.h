#pragma once

#include <QAbstractListModel>
#include <QVector>

class DatabaseManager;

/**
 * @brief QML list model and state controller for ventilator alarms.
 *
 * The model exposes rows with time, priority, source, description, and status
 * roles. It also exposes current alarm banner state through properties.
 */
class AlarmController : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY bannerChanged)
    Q_PROPERTY(QString priority READ priority WRITE setPriority NOTIFY bannerChanged)
    Q_PROPERTY(QString headline READ headline WRITE setHeadline NOTIFY bannerChanged)
    Q_PROPERTY(QString detail READ detail WRITE setDetail NOTIFY bannerChanged)

public:
    enum AlarmRoles {
        TimeRole = Qt::UserRole + 1,
        PriorityRole,
        SourceRole,
        DescriptionRole,
        StatusRole
    };

    explicit AlarmController(DatabaseManager *database, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool active() const;
    QString priority() const;
    QString headline() const;
    QString detail() const;

    Q_INVOKABLE void acknowledgeActiveAlarm();
    Q_INVOKABLE void addAlarm(const QString &priority,
                              const QString &source,
                              const QString &description,
                              const QString &status);

public slots:
    void setActive(bool value);
    void setPriority(const QString &value);
    void setHeadline(const QString &value);
    void setDetail(const QString &value);

signals:
    void bannerChanged();

private:
    struct AlarmRow {
        QString time;
        QString priority;
        QString source;
        QString description;
        QString status;
    };

    QVector<AlarmRow> m_rows;
    DatabaseManager *m_database = nullptr;
    bool m_active = false;
    QString m_priority = QStringLiteral("Normal");
    QString m_headline = QStringLiteral("No Active Alarms");
    QString m_detail = QStringLiteral("System normal");
};
