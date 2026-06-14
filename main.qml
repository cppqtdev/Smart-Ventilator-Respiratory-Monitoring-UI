pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: main.qml
// Description: Root ApplicationWindow with screen routing and controller bindings
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic

import "qml/styles"
import "qml/components/navigation"
import "qml/components/indicators"
import "qml/screens"

ApplicationWindow {
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
    property var eventModel: eventController
    property string currentScreen: "standby"
    property bool ventilationActive: ventilatorModel.running
    property bool alarmVisible: alarmModel.active
    property bool splashActive: true

    function navigateToScreen() {
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
        if (root.currentScreen === "shutdown")
            return shutdownScreen
        if (root.currentScreen === "emergency")
            return emergencyScreen
        return monitoringScreen
    }

    header: AppHeader {
        id: header
        visible: !root.splashActive
        alarmData: alarmModel
        clockData: clockController
        showAlarm: root.alarmVisible
        mode: ventilatorModel.mode
        patientCategory: patientModel.category
    }

    Control {
        leftPadding: Spacing.screenMargin
        rightPadding: Spacing.screenMargin
        width: parent.width
        height: parent.height

        contentItem: Loader {
            id: screenLoader
            active: !root.splashActive
            sourceComponent: navigateToScreen()
        }
    }

    footer: BottomNavigation {
        id: bottomNav
        visible: !root.splashActive
        padding: Spacing.screenMargin
        currentScreen: root.currentScreen
        onNavigate: function(screen) {
            root.currentScreen = screen
            if (screen === "monitoring")
                root.ventilatorModel.startVentilation()
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
            eventData: eventModel
        }
    }

    Component {
        id: toolsScreen
        ToolsScreen {
            ventilatorData: ventilatorModel
            eventData: eventModel
        }
    }

    Component {
        id: layoutScreen
        LayoutScreen {}
    }

    Component {
        id: shutdownScreen
        ShutdownScreen {
            ventilatorData: ventilatorModel
            alarmData: alarmModel
            onShutdownConfirmed: root.currentScreen = "standby"
            onShutdownCancelled: root.currentScreen = "monitoring"
        }
    }

    Component {
        id: emergencyScreen
        EmergencyScreen {
            ventilatorData: ventilatorModel
            alarmData: alarmModel
            onExitEmergency: root.currentScreen = "monitoring"
        }
    }
}
