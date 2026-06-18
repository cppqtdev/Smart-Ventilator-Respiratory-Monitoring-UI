QT += quick quickcontrols2 sql multimedia

APP_VERSION = $$(APP_VERSION)
isEmpty(APP_VERSION): APP_VERSION = 0.1.0-dev
BUILD_ID = $$(BUILD_ID)
isEmpty(BUILD_ID): BUILD_ID = local
DEFINES += APP_VERSION=\\\"$${APP_VERSION}\\\" BUILD_ID=\\\"$${BUILD_ID}\\\"

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
        src/core/AppSettings.cpp \
        src/core/DatabaseManager.cpp \
        src/controllers/AlarmController.cpp \
        src/controllers/ClockController.cpp \
        src/controllers/EventController.cpp \
        src/controllers/UserController.cpp \
        src/controllers/PatientController.cpp \
        src/controllers/VentilatorController.cpp

HEADERS += \
        src/core/AppSettings.h \
        src/core/DatabaseManager.h \
        src/controllers/AlarmController.h \
        src/controllers/ClockController.h \
        src/controllers/EventController.h \
        src/controllers/UserController.h \
        src/controllers/PatientController.h \
        src/controllers/VentilatorController.h

INCLUDEPATH += .

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
