#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QByteArray>
#include <QDebug>

#include "src/core/AppSettings.h"
#include "src/core/DatabaseManager.h"
#include "src/controllers/AlarmController.h"
#include "src/controllers/ClockController.h"
#include "src/controllers/PatientController.h"
#include "src/controllers/EventController.h"
#include "src/controllers/UserController.h"
#include "src/controllers/VentilatorController.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("Basic"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QGuiApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("AlsonsTechnology"));
    QCoreApplication::setApplicationName(QStringLiteral("SmartVentilatorDemo"));

    DatabaseManager databaseManager;
    const bool databaseReady = databaseManager.initialize();
    if (!databaseReady)
        qCritical() << "Database initialization failed:" << databaseManager.lastError();
    AppSettings appSettings;
    PatientController patientController(&databaseManager);
    AlarmController alarmController(&databaseManager);
    if (!databaseReady) {
        alarmController.addAlarm(QStringLiteral("Critical"),
                                 QStringLiteral("Storage"),
                                 QStringLiteral("Database unavailable -- audit trail and patient persistence degraded"),
                                 QStringLiteral("Active"));
        alarmController.setActive(true);
        alarmController.setPriority(QStringLiteral("Critical"));
        alarmController.setHeadline(QStringLiteral("Storage Failure"));
        alarmController.setDetail(QStringLiteral("Audit trail unavailable"));
    }
    EventController eventController(&databaseManager);
    UserController userController(&databaseManager);
    VentilatorController ventilatorController(&databaseManager, &alarmController);
    ClockController clockController;

    auto updateVentilatorPatientContext = [&]() {
        ventilatorController.setPatientContext(patientController.category());
        ventilatorController.setPatientIbwKg(patientController.ibw());
    };
    updateVentilatorPatientContext();
    QObject::connect(&patientController, &PatientController::patientChanged,
                     &ventilatorController, updateVentilatorPatientContext);

    QObject::connect(&userController, &UserController::sessionChanged,
                     &ventilatorController, [&]() {
        ventilatorController.setOperatorId(userController.loggedIn()
            ? userController.currentUser()
            : QStringLiteral("unauthenticated"));
    });

    QObject::connect(&databaseManager, &DatabaseManager::errorOccurred,
                     &alarmController, [&](const QString &message) {
        alarmController.raiseAlarm(QStringLiteral("Critical"),
                                   QStringLiteral("Storage"),
                                   QStringLiteral("Storage Failure"),
                                   message);
    });
    QObject::connect(&ventilatorController, &VentilatorController::backendStateChanged,
                     &alarmController, [&]() {
        if (ventilatorController.degradedMode()) {
            alarmController.raiseAlarm(QStringLiteral("Critical"),
                                       QStringLiteral("Backend"),
                                       QStringLiteral("Backend Disconnected"),
                                       ventilatorController.backendState());
        }
    });

    // Restore persisted timezone from QSettings.
    clockController.setTimeZoneId(appSettings.timeZoneId());

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("appSettings"), &appSettings);
    engine.rootContext()->setContextProperty(QStringLiteral("databaseManager"), &databaseManager);
    engine.rootContext()->setContextProperty(QStringLiteral("patientController"), &patientController);
    engine.rootContext()->setContextProperty(QStringLiteral("alarmController"), &alarmController);
    engine.rootContext()->setContextProperty(QStringLiteral("eventController"), &eventController);
    engine.rootContext()->setContextProperty(QStringLiteral("userController"), &userController);
    engine.rootContext()->setContextProperty(QStringLiteral("ventilatorController"), &ventilatorController);
    engine.rootContext()->setContextProperty(QStringLiteral("clockController"), &clockController);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
