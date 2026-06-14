#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QByteArray>

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
    databaseManager.initialize();
    AppSettings appSettings;
    PatientController patientController(&databaseManager);
    AlarmController alarmController(&databaseManager);
    EventController eventController(&databaseManager);
    UserController userController(&databaseManager);
    VentilatorController ventilatorController(&databaseManager, &alarmController);
    ClockController clockController;

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
