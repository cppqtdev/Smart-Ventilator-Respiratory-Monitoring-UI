pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: main.qml
// Description: Root ApplicationWindow with screen routing and controller bindings
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import QtMultimedia

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
    property string currentScreen: "login"
    property string operatorRole: ""
    property bool ventilationActive: ventilatorModel.running
    property bool alarmVisible: alarmModel.active
    property bool splashActive: true
    property string clinicalAutomationStatus: ""

    function updateColorMode() {
        var mode = appSettings.dayNightMode
        var hour = new Date().getHours()
        var nightStart = appSettings.nightStartHour
        var dayStart = appSettings.dayStartHour
        var scheduledNight = nightStart > dayStart
            ? (hour >= nightStart || hour < dayStart)
            : (hour >= nightStart && hour < dayStart)
        Colors.nightMode = mode === "Night"
            || (mode === "Automatic" && scheduledNight)
    }

    function navigateToScreen() {
        if (root.currentScreen === "login")
            return loginScreen
        if (root.currentScreen === "standby")
            return standbyScreen
        if (root.currentScreen === "patient")
            return patientScreen
        if (root.currentScreen === "modes")
            return modeScreen
        if (root.currentScreen === "controls")
            return controlsScreen
        if (root.currentScreen === "trends")
            return trendsScreen
        if (root.currentScreen === "loops")
            return loopsScreen
        if (root.currentScreen === "clinical")
            return clinicalScreen
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
        if (root.currentScreen === "target")
            return targetScreen
        if (root.currentScreen === "settings")
            return settingsScreen
        if (root.currentScreen === "shutdown")
            return shutdownScreen
        if (root.currentScreen === "emergency")
            return emergencyScreen
        return monitoringScreen
    }

    header: AppHeader {
        id: header
        visible: !root.splashActive && root.currentScreen !== "login"
        alarmData: alarmModel
        clockData: clockController
        showAlarm: root.alarmVisible
        mode: ventilatorModel.mode
        patientCategory: patientModel.category
        patientData: patientModel
        automationStatus: root.clinicalAutomationStatus
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
        visible: !root.splashActive && root.currentScreen !== "login"
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

    Component.onCompleted: root.updateColorMode()

    Connections {
        target: appSettings
        function onDayNightModeChanged() {
            root.updateColorMode()
        }
        function onDayNightScheduleChanged() {
            root.updateColorMode()
        }
    }

    Timer {
        interval: 60000
        running: appSettings.dayNightMode === "Automatic"
        repeat: true
        onTriggered: root.updateColorMode()
    }

    // IEC 60601-1-8 alarm audio: always alive in the root window so the
    // alarm tone plays regardless of which screen is currently loaded.
    MediaPlayer {
        id: alarmAudioPlayer
        source: "qrc:/qml/assets/audio/alarm_tone.wav"
        loops: MediaPlayer.Infinite
        audioOutput: AudioOutput {
            volume: root.alarmModel.audioActive ? 0.8 : 0.0
        }
    }

    Connections {
        target: root.alarmModel
        function onAudioChanged() {
            if (root.alarmModel.audioActive)
                alarmAudioPlayer.play()
            else
                alarmAudioPlayer.stop()
        }
    }

    // Global interaction detector to reset the screen lock timer.
    MouseArea {
        anchors.fill: parent
        z: 999
        propagateComposedEvents: true
        onPressed: function(mouse) {
            screenLock.resetTimer()
            mouse.accepted = false
        }
    }

    ScreenLockOverlay {
        id: screenLock
        anchors.fill: parent
        timeoutSeconds: userController.lockTimeoutSeconds
    }

    Component {
        id: loginScreen
        LoginScreen {
            userControllerData: userController
            onLoginAccepted: function(role) {
                root.operatorRole = role
                root.currentScreen = "standby"
            }
        }
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
            layoutPreset: appSettings.monitoringLayout
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
        id: trendsScreen
        TrendsScreen {
            ventilatorData: ventilatorModel
            databaseData: databaseManager
        }
    }

    Component {
        id: loopsScreen
        LoopsScreen {
            ventilatorData: ventilatorModel
        }
    }

    Component {
        id: clinicalScreen
        ClinicalScreen {
            patientData: patientModel
            ventilatorData: ventilatorModel
            eventData: eventModel
            databaseData: databaseManager
            alarmData: alarmModel
            appSettingsData: appSettings
            onGlobalStatusChanged: root.clinicalAutomationStatus = globalStatus
            Component.onCompleted: root.clinicalAutomationStatus = globalStatus
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
            alarmData: alarmModel
            eventData: eventModel
        }
    }

    Component {
        id: layoutScreen
        LayoutScreen {
            appSettingsData: appSettings
        }
    }

    Component {
        id: targetScreen
        TargetScreen {
            ventilatorData: ventilatorModel
        }
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

    Component {
        id: settingsScreen
        SettingsScreen {
            appSettingsData: appSettings
            userControllerData: userController
            clockData: clockController
        }
    }
}
