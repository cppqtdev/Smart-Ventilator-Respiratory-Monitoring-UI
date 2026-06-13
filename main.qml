pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Window 2.15
import "qml/styles"
import "qml/components/navigation"
import "qml/components/indicators"
import "qml/screens"

Window {
    id: root
    width: 1920
    height: 1080
    minimumWidth: 1366
    minimumHeight: 768
    visible: true
    color: Colors.background
    title: qsTr("ICU Smart Ventilator Demo")

    property var patientModel: patientController
    property var ventilatorModel: ventilatorController
    property var alarmModel: alarmController
    property string currentScreen: "standby"
    property bool ventilationActive: ventilatorModel.running
    property bool alarmVisible: alarmModel.active
    property bool splashActive: true

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        visible: !root.splashActive

        AppHeader {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: Math.max(92, root.height * 0.118)
            alarmData: alarmModel
            clockData: clockController
            showAlarm: root.alarmVisible
            mode: ventilatorModel.mode
            patientCategory: patientModel.category
        }

        Loader {
            id: screenLoader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: bottomNav.top
            anchors.margins: Spacing.screenMargin
            sourceComponent: {
                if (root.currentScreen === "standby")
                    return standbyScreen
                if (root.currentScreen === "patient")
                    return patientScreen
                if (root.currentScreen === "modes")
                    return modeScreen
                if (root.currentScreen === "controls")
                    return controlsScreen
                if (root.currentScreen === "alarms")
                    return alarmScreen
                if (root.currentScreen === "system")
                    return systemScreen
                if (root.currentScreen === "events")
                    return eventsScreen
                if (root.currentScreen === "tools")
                    return toolsScreen
                if (root.currentScreen === "layout")
                    return layoutScreen
                return monitoringScreen
            }
        }

        BottomNavigation {
            id: bottomNav
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Spacing.screenMargin
            height: Math.max(74, root.height * 0.085)
            currentScreen: root.currentScreen
            onNavigate: function(screen) {
                root.currentScreen = screen
                if (screen === "monitoring")
                    root.ventilatorModel.startVentilation()
            }
        }
    }

    SplashScreen {
        anchors.fill: parent
        visible: root.splashActive
        softwareVersion: appSettings.softwareVersion
        operatingHours: appSettings.operatingHours
        onFinished: root.splashActive = false
    }

    Component {
        id: standbyScreen
        StandbyScreen {
            patientData: patientModel
            ventilatorData: ventilatorModel
            onStartRequested: {
                root.ventilatorModel.startVentilation()
                root.currentScreen = "monitoring"
            }
            onSetupRequested: {
                root.ventilatorModel.runCalibration()
                root.currentScreen = "patient"
            }
        }
    }

    Component {
        id: patientScreen
        PatientSetupScreen {
            patientData: patientModel
            onContinueRequested: root.currentScreen = "modes"
        }
    }

    Component {
        id: modeScreen
        ModeSelectionScreen {
            ventilatorData: ventilatorModel
            onModeConfirmed: {
                root.ventilatorModel.startVentilation()
                root.currentScreen = "monitoring"
            }
        }
    }

    Component {
        id: monitoringScreen
        MonitoringScreen {
            patientData: patientModel
            ventilatorData: ventilatorModel
            alarmData: alarmModel
        }
    }

    Component {
        id: controlsScreen
        ControlsScreen {
            patientData: root.patientModel
            ventilatorData: ventilatorModel
        }
    }

    Component {
        id: alarmScreen
        AlarmCenterScreen {
            alarmData: alarmModel
        }
    }

    Component {
        id: systemScreen
        SystemDiagnosticsScreen {
            clockData: clockController
            appSettingsData: appSettings
        }
    }

    Component {
        id: eventsScreen
        EventsScreen {
            alarmData: alarmModel
        }
    }

    Component {
        id: toolsScreen
        ToolsScreen {
            ventilatorData: ventilatorModel
        }
    }

    Component {
        id: layoutScreen
        LayoutScreen {}
    }
}
