pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: ClinicalScreen.qml
// Description: Clinical workflows: admit, therapy, weaning, maneuvers, export,
//              reference, network/power, maintenance, and central monitoring
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../styles"
import "../components/cards"
import "../components/buttons"

Page {
    id: root

    property var patientData
    property var ventilatorData
    property var eventData
    property var databaseData
    property var alarmData
    property var appSettingsData
    property int currentTab: 0
    property string actionMessage: ""

    onCurrentTabChanged: root.actionMessage = ""

    // Auto-dismiss status message after 5 seconds
    Timer {
        id: messageDismissTimer
        interval: 5000
        onTriggered: root.actionMessage = ""
    }

    onActionMessageChanged: {
        if (root.actionMessage.length > 0)
            messageDismissTimer.restart()
    }

    // Therapy state
    property bool humidifierEnabled: true
    property int humidifierTemperature: 37
    property real humidifierActualTemperature: 35
    property int humidifierWaterLevel: 72
    property bool humidifierWarningRaised: false
    property bool nebulizerRunning: false
    property int nebulizerMinutes: 10
    property string nebulizerMedication: "Salbutamol"
    property int nebulizerSecondsRemaining: 0

    // Weaning state
    property bool sbtRunning: false
    property int sbtMinutes: 0

    // Power/network state
    property string networkType: "Ethernet"
    property string networkAddress: "10.20.30.41"
    property string fhirEndpoint: "https://hospital.example/fhir"
    property bool remoteConnected: true
    property int batteryLevel: 86
    property bool acPower: true
    property bool batteryWarningRaised: false
    property bool batteryCriticalRaised: false

    // History data
    property var sbtHistory: []
    property var maintenanceHistory: []
    property var maneuverHistory: []
    property var maintenanceSchedules: []
    property var centralPatients: []
    property string referenceSearch: ""

    readonly property string globalStatus: {
        var parts = []
        if (root.sbtRunning)
        parts.push("SBT " + root.sbtMinutes + "m")
        if (root.nebulizerRunning)
        parts.push("NEB")
        parts.push(root.acPower ? "AC" : "BAT " + root.batteryLevel + "%")
        parts.push(root.remoteConnected ? "NET" : "OFFLINE")
        return parts.join(" | ")
    }

    readonly property real rsbi: root.ventilatorData
                                 && root.ventilatorData.vte > 0
                                 ? root.ventilatorData.ftotal
                                   / (root.ventilatorData.vte / 1000.0) : 0

    readonly property var tabs: [
        "Admit", "Therapy", "Weaning", "Maneuvers", "Export",
        "Reference", "Network", "Maintenance", "Central"
    ]

    function logAction(source, desc) {
        root.actionMessage = desc
        if (root.eventData)
            root.eventData.addEvent(source, desc, "normal")
    }

    function saveState(key, value) {
        if (root.databaseData)
            root.databaseData.saveClinicalState(key, value)
    }

    function restoreState() {
        if (!root.databaseData) return
        var s = root.databaseData.loadClinicalState()
        if (s.humidifierEnabled !== undefined)
            root.humidifierEnabled = s.humidifierEnabled === "true"
        if (s.humidifierTemperature !== undefined)
            root.humidifierTemperature = Number(s.humidifierTemperature)
        if (s.nebulizerMinutes !== undefined)
            root.nebulizerMinutes = Number(s.nebulizerMinutes)
        if (s.nebulizerMedication !== undefined)
            root.nebulizerMedication = s.nebulizerMedication
        if (s.remoteConnected !== undefined)
            root.remoteConnected = s.remoteConnected === "true"
        if (s.batteryLevel !== undefined)
            root.batteryLevel = Number(s.batteryLevel)
        if (s.acPower !== undefined)
            root.acPower = s.acPower === "true"
    }

    function refreshHistories() {
        if (!root.databaseData) return
        root.sbtHistory = root.databaseData.getSbtHistory(20)
        root.maintenanceHistory = root.databaseData.getMaintenanceHistory(20)
        root.maneuverHistory = root.databaseData.getManeuverHistory(20)
        root.maintenanceSchedules = root.databaseData.getMaintenanceSchedules()
        root.centralPatients = root.databaseData.getCentralPatients()
        if (root.maintenanceSchedules.length === 0) {
            var defaults = [
                        ["Patient circuit", "2026-06-16"],
                        ["Bacterial filter", "2026-06-18"],
                        ["Flow sensor calibration", "2026-06-27"],
                        ["Preventive maintenance", "2026-07-15"]
                    ]
            for (var i = 0; i < defaults.length; ++i)
                root.databaseData.saveMaintenanceSchedule(
                            defaults[i][0], defaults[i][1], false)
            root.maintenanceSchedules
                    = root.databaseData.getMaintenanceSchedules()
        }
        if (root.centralPatients.length === 0) {
            var pts = [
                        {
                            bed: "ICU-08", patientId: "ICU-24002",
                            spo2: 94, ppeak: 28, status: "Stable"
                        },
                        {
                            bed: "ICU-09", patientId: "ICU-24003",
                            spo2: 89, ppeak: 42, status: "Alarm"
                        },
                        {
                            bed: "ICU-10", patientId: "ICU-24004",
                            spo2: 97, ppeak: 24, status: "Weaning"
                        }
                    ]
            for (var j = 0; j < pts.length; ++j)
                root.databaseData.saveCentralPatient(pts[j])
            root.centralPatients = root.databaseData.getCentralPatients()
        }
    }

    function finishSbt(status, message) {
        root.sbtRunning = false
        if (root.databaseData)
            root.databaseData.recordSbtSession({
                                                   status: status,
                                                   rsbi: root.rsbi,
                                                   spo2: root.ventilatorData.spo2,
                                                   fio2: root.ventilatorData.fio2,
                                                   peep: root.ventilatorData.peep
                                               })
        root.refreshHistories()
        root.logAction("Weaning", message)
        if (status === "Failed" && root.alarmData) {
            root.alarmData.raiseAlarm("Warning", "Weaning",
                                      "SBT Stopped", message)
        }
    }

    function evaluateBattery() {
        if (root.acPower) {
            root.batteryWarningRaised = false
            root.batteryCriticalRaised = false
            return
        }
        if (root.batteryLevel <= 10 && !root.batteryCriticalRaised) {
            root.batteryCriticalRaised = true
            if (root.appSettingsData)
                root.appSettingsData.dayNightMode = "Night"
            raisePowerAlarm("Critical", "Battery critical",
                            "Battery at " + root.batteryLevel + "%")
        } else if (root.batteryLevel <= 20
                   && !root.batteryWarningRaised) {
            root.batteryWarningRaised = true
            raisePowerAlarm("Warning", "Low battery",
                            "Battery at " + root.batteryLevel + "%")
        }
    }

    function raisePowerAlarm(priority, headline, detail) {
        if (!root.alarmData) return
        root.alarmData.raiseAlarm(priority, "Power", headline, detail)
    }

    function recordManeuver(type, result, unit, notes) {
        if (root.databaseData)
            root.databaseData.recordManeuver(type, result, unit, notes)
        root.refreshHistories()
        root.logAction("Maneuver",
                       type + " recorded: " + result + " " + unit)
    }

    Component.onCompleted: {
        root.restoreState()
        root.refreshHistories()
        root.evaluateBattery()
    }

    // -----------------------------------------------------------------
    // Timers
    // -----------------------------------------------------------------

    Timer {
        interval: 60000
        running: root.sbtRunning
        repeat: true
        onTriggered: {
            root.sbtMinutes += 1
            if (root.sbtMinutes >= 30) {
                root.finishSbt("Completed",
                    "SBT completed after 30 minutes")
            }
        }
    }

    Timer {
        interval: 3000
        running: root.humidifierEnabled
        repeat: true
        onTriggered: {
            var d = root.humidifierTemperature
            - root.humidifierActualTemperature
            root.humidifierActualTemperature
            += Math.max(-0.4, Math.min(0.4, d))
            if (root.nebulizerRunning && root.humidifierWaterLevel > 0) {
                root.humidifierWaterLevel -= 1
            }
            if (root.humidifierWaterLevel <= 15
                && !root.humidifierWarningRaised) {
                root.humidifierWarningRaised = true
                raisePowerAlarm("Warning", "Humidifier water low",
                                "Water level at " + root.humidifierWaterLevel + "%")
            }
        }
    }

    Timer {
        interval: 5000
        running: root.sbtRunning
        repeat: true
        onTriggered: {
            if (root.ventilatorData.spo2 > 0
                    && root.ventilatorData.spo2 < 88) {
                root.finishSbt("Failed", "SpO2 below 88%")
            } else if (root.rsbi > 120) {
                root.finishSbt("Failed", "RSBI above 120")
            }
        }
    }

    Timer {
        interval: 1000
        running: root.nebulizerRunning
        repeat: true
        onTriggered: {
            root.nebulizerSecondsRemaining -= 1
            if (root.nebulizerSecondsRemaining <= 0) {
                root.nebulizerRunning = false
                root.logAction("Therapy", "Nebulizer cycle completed")
            }
        }
    }

    Timer {
        interval: 60000
        running: !root.acPower && root.batteryLevel > 0
        repeat: true
        onTriggered: {
            root.batteryLevel = Math.max(0, root.batteryLevel - 1)
            root.saveState("batteryLevel", root.batteryLevel)
            root.evaluateBattery()
        }
    }

    background: Rectangle {
        color: Colors.surface
        radius: Radius.medium
        border.color: Colors.line
    }

    // Tab header using PrefsTabButton, filling width
    header: Control {
        padding: 24

        contentItem: RowLayout {

            spacing: 8

            Repeater {
                model: root.tabs

                PrefsTabButton {
                    required property string modelData
                    required property int index
                    Layout.fillWidth: true
                    height: 44
                    text: modelData
                    checked: root.currentTab === index
                    onClicked: root.currentTab = index
                }
            }
        }
    }

    contentItem: Flickable {
        contentWidth: width
        contentHeight: workspace.height + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        Control {
            id: content
            width: root.width
            padding: 24

            contentItem: ColumnLayout {
                id: workspace
                spacing: 18

                Text {
                    Layout.fillWidth: true
                    text: root.tabs[root.currentTab]
                    color: Colors.textPrimary
                    font.pixelSize: Typography.title
                    font.weight: Font.DemiBold
                }

                // -----------------------------------------------------------------
                // TAB 0: Admit -- Patient admission and discharge
                // -----------------------------------------------------------------

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 18
                    rowSpacing: 14
                    visible: root.currentTab === 0

                    Text {
                        text: "Patient ID"
                        color: Colors.textMuted
                        font.pixelSize: Typography.caption
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        text: root.patientData ? root.patientData.patientId : ""
                        onEditingFinished: { if (root.patientData) root.patientData.patientId = text }
                    }

                    Text {
                        text: "Bed Number"
                        color: Colors.textMuted
                        font.pixelSize: Typography.caption
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        text: root.patientData ? root.patientData.bedNumber : ""
                        onEditingFinished: { if (root.patientData) root.patientData.bedNumber = text }
                    }

                    Text {
                        text: "Physician"
                        color: Colors.textMuted
                        font.pixelSize: Typography.caption
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        text: root.patientData ? root.patientData.physician : ""
                        onEditingFinished: { if (root.patientData) root.patientData.physician = text }
                    }

                    Text {
                        text: "Admit Date"
                        color: Colors.textMuted
                        font.pixelSize: Typography.caption
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        text: root.patientData ? root.patientData.admitDate : ""
                        placeholderText: "YYYY-MM-DD"
                        onEditingFinished: { if (root.patientData) root.patientData.admitDate = text }
                    }

                    Row {
                        Layout.columnSpan: 2
                        spacing: 16

                        PrimaryButton {
                            width: 200
                            text: "Admit / Update"
                            buttonColor: Colors.success
                            onClicked: {
                                if (root.patientData) root.patientData.saveProfile()
                                root.logAction("Patient", "Admission updated")
                            }
                        }

                        PrimaryButton {
                            width: 160
                            text: "Discharge"
                            buttonColor: Colors.critical
                            onClicked: {
                                root.logAction("Patient", "Patient discharged")
                                if (root.patientData) {
                                    root.patientData.patientId = ""
                                    root.patientData.bedNumber = ""
                                    root.patientData.physician = ""
                                    root.patientData.saveProfile()
                                }
                            }
                        }
                    }
                }

                // -----------------------------------------------------------------
                // TAB 1: Therapy -- Humidifier and Nebulizer controls
                // -----------------------------------------------------------------

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.currentTab === 1
                    spacing: 24

                    // Humidifier panel
                    Control {
                        Layout.preferredWidth: content.width / 2 - padding - parent.spacing / 2
                        Layout.preferredHeight: nebulizer_panel.implicitHeight
                        padding: 24

                        background: Rectangle {
                            radius: Radius.medium
                            color: Colors.surface
                            border.color: Colors.line
                            border.width: 1
                        }

                        contentItem: Column {
                            spacing: 14

                            Text {
                                text: "Heated Humidifier"
                                color: Colors.textPrimary
                                font.pixelSize: Typography.subtitle
                                font.weight: Font.DemiBold
                            }

                            Text {
                                width: parent.width
                                text: root.humidifierEnabled ? "Target " + root.humidifierTemperature
                                        + " C  |  Actual "
                                        + root.humidifierActualTemperature.toFixed(1)
                                        + " C  |  Water "
                                        + root.humidifierWaterLevel + "%" : "Disabled"
                                color: Colors.textSecondary
                                font.pixelSize: Typography.body
                                wrapMode: Text.WordWrap
                            }

                            PrimaryButton {
                                width: 160
                                height: 44
                                text: root.humidifierEnabled ? "Disable" : "Enable"
                                buttonColor: root.humidifierEnabled ? Colors.critical : Colors.success
                                onClicked: {
                                    root.humidifierEnabled = !root.humidifierEnabled
                                    root.saveState("humidifierEnabled", root.humidifierEnabled)
                                    root.logAction("Therapy", "Humidifier " + (root.humidifierEnabled ? "enabled" : "disabled"))
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 12

                                Text {
                                    text: "Temperature"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.caption
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledSlider {
                                    width: parent.width - 120
                                    from: 31
                                    to: 39
                                    stepSize: 1
                                    value: root.humidifierTemperature
                                    onMoved: {
                                        root.humidifierTemperature = value
                                        root.saveState("humidifierTemperature", value)
                                    }
                                }
                            }
                        }
                    }

                    // Nebulizer panel
                    Control {
                        id: nebulizer_panel
                        Layout.preferredWidth: content.width / 2 - padding - parent.spacing / 2
                        padding: 24

                        background: Rectangle {
                            radius: Radius.medium
                            color: Colors.surface
                            border.color: Colors.line
                            border.width: 1
                        }

                        contentItem: Column {
                            id: nebCol
                            spacing: 14

                            Text {
                                text: "Nebulizer"
                                color: Colors.textPrimary
                                font.pixelSize: Typography.subtitle
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: root.nebulizerRunning ? "Running  |  " + Math.floor(root.nebulizerSecondsRemaining / 60) + ":"
                                        + (root.nebulizerSecondsRemaining % 60 < 10 ? "0" : "")
                                        + (root.nebulizerSecondsRemaining % 60)
                                        + " remaining" : "Ready"
                                color: root.nebulizerRunning ? Colors.successBright : Colors.textSecondary
                                font.pixelSize: Typography.body
                            }

                            PrimaryButton {
                                width: 160
                                text: root.nebulizerRunning ? "Stop" : "Start"
                                buttonColor: root.nebulizerRunning ? Colors.critical : Colors.success
                                onClicked: {
                                    root.nebulizerRunning = !root.nebulizerRunning

                                    if (root.nebulizerRunning)
                                    root.nebulizerSecondsRemaining = root.nebulizerMinutes * 60

                                    root.logAction("Therapy", "Nebulizer " + (root.nebulizerRunning ? "started" : "stopped"))
                                }
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 12

                                Text {
                                    Layout.fillWidth: true
                                    text: "Medication"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.caption
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                StyledTextField {
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    Layout.preferredWidth: 250
                                    text: root.nebulizerMedication
                                    onEditingFinished: {
                                        root.nebulizerMedication = text
                                        root.saveState("nebulizerMedication", text)
                                    }
                                }
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 12

                                Text {
                                    Layout.fillWidth: true
                                    text: "Duration (min)"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.caption
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                StyledSpinBox {
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    from: 1
                                    to: 60
                                    value: root.nebulizerMinutes
                                    onValueModified: {
                                        root.nebulizerMinutes = value
                                        root.saveState("nebulizerMinutes", value)
                                    }
                                }
                            }
                        }
                    }
                }

                // -----------------------------------------------------------------
                // TAB 2: Weaning -- SBT management and history
                // -----------------------------------------------------------------

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 2

                    contentItem: ColumnLayout {
                        spacing: 16

                        RowLayout {

                            Layout.fillWidth: true
                            spacing: 14

                            MetricTile {
                                Layout.fillWidth: true
                                height: 110
                                label: "RSBI"
                                value: Math.round(root.rsbi)
                                unit: "br/min/L"
                            }

                            MetricTile {
                                Layout.fillWidth: true
                                height: 110
                                label: "SpO2"
                                value: root.ventilatorData ? root.ventilatorData.spo2 : 0
                                unit: "%"
                            }

                            MetricTile {
                                Layout.fillWidth: true
                                height: 110
                                label: "PEEP"
                                value: root.ventilatorData ? root.ventilatorData.peep : 0
                                unit: "cmH2O"
                            }

                            MetricTile {
                                Layout.fillWidth: true
                                height: 110
                                label: "FiO2"
                                value: root.ventilatorData ? root.ventilatorData.fio2 : 0
                                unit: "%"
                            }

                            MetricTile {
                                Layout.fillWidth: true
                                height: 110
                                label: "WOB"
                                value: root.ventilatorData ? root.ventilatorData.workOfBreathing : 0
                                unit: "J/L"
                            }

                            MetricTile {
                                Layout.fillWidth: true
                                height: 110
                                label: "Stress Idx"
                                value: root.ventilatorData ? root.ventilatorData.stressIndex : 0
                                unit: ""
                                state: root.ventilatorData
                                    && root.ventilatorData.stressIndex > 1.3
                                    ? "warning" : "normal"
                            }

                            MetricTile {
                                Layout.fillWidth: true
                                height: 110
                                label: "Vd/Vt"
                                value: root.ventilatorData ? root.ventilatorData.deadSpaceFraction : 0
                                unit: ""
                                state: root.ventilatorData
                                    && root.ventilatorData.deadSpaceFraction > 0.5
                                    ? "warning" : "normal"
                            }

                            MetricTile {
                                Layout.fillWidth: true
                                height: 110
                                label: "O2 Timer"
                                value: root.ventilatorData ? root.ventilatorData.highFio2Minutes : 0
                                unit: "min"
                                state: root.ventilatorData
                                    && root.ventilatorData.highFio2Minutes > 120
                                    ? "warning" : "normal"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.rsbi > 0 && root.rsbi < 105
                                  && root.ventilatorData
                                  && root.ventilatorData.spo2 >= 92
                                  ? "Readiness: favorable for supervised SBT"
                                  : "Readiness: review oxygenation and respiratory load"
                            color: root.rsbi > 0 && root.rsbi < 105
                                   ? Colors.successBright : Colors.warning
                            font.pixelSize: Typography.body
                            font.weight: Font.DemiBold
                        }

                        PrimaryButton {
                            width: 280
                            text: root.sbtRunning
                                  ? "Stop SBT (" + root.sbtMinutes + " min)"
                                  : "Start 30 min SBT"
                            buttonColor: root.sbtRunning
                                         ? Colors.critical : Colors.success
                            onClicked: {
                                if (!root.sbtRunning) {
                                    root.sbtRunning = true
                                    root.sbtMinutes = 0
                                    if (root.databaseData)
                                    root.databaseData.recordSbtSession({
                                                                           status: "Started",
                                                                           rsbi: root.rsbi,
                                                                           spo2: root.ventilatorData.spo2,
                                                                           fio2: root.ventilatorData.fio2,
                                                                           peep: root.ventilatorData.peep
                                                                       })
                                    root.refreshHistories()
                                    root.logAction("Weaning", "SBT started")
                                } else {
                                    root.finishSbt("Stopped", "SBT stopped by operator")
                                }
                            }
                        }

                        Text {
                            text: "Recent SBT Sessions"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.subtitle
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: root.sbtHistory

                            Panel {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 58

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 20

                                    Text {
                                        width: 180
                                        text: modelData.time
                                        color: Colors.textMuted
                                        font.pixelSize: Typography.caption
                                        font.family: Typography.monoFamily
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: 90
                                        text: modelData.status
                                        color: modelData.status === "Failed" ? Colors.critical : Colors.successBright
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "RSBI " + Math.round(modelData.rsbi)
                                        color: Colors.textSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "SpO2 " + modelData.spo2 + "%"
                                        color: Colors.textSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }


                // -----------------------------------------------------------------
                // TAB 3: Maneuvers -- Inspiratory/expiratory holds and history
                // -----------------------------------------------------------------

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 3

                    contentItem: ColumnLayout {
                        spacing: 16

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 18

                            Control {
                                Layout.fillWidth: true
                                padding: 18

                                background: Rectangle {
                                    implicitHeight: 150
                                    radius: Radius.medium
                                    color: Colors.surface
                                    border.color: Colors.line
                                    border.width: 1
                                }

                                contentItem: Column {
                                    spacing: 12

                                    Text {
                                        text: "Inspiratory Hold"
                                        color: Colors.textPrimary
                                        font.pixelSize: Typography.subtitle
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: "Measures plateau pressure (Pplat)"
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.body
                                    }

                                    PrimaryButton {
                                        width: 160
                                        text: "Hold 3 s"
                                        buttonColor: Colors.accentBlue
                                        onClicked: root.recordManeuver(
                                                       "Inspiratory hold",
                                                       root.ventilatorData
                                                       ? root.ventilatorData.pplat : 0,
                                                       "cmH2O", "Plateau pressure")
                                    }
                                }
                            }

                            Control {
                                Layout.fillWidth: true
                                padding: 18

                                background: Rectangle {
                                    implicitHeight: 150
                                    radius: Radius.medium
                                    color: Colors.surface
                                    border.color: Colors.line
                                    border.width: 1
                                }

                                contentItem: Column {
                                    spacing: 12

                                    Text {
                                        text: "Expiratory Hold"
                                        color: Colors.textPrimary
                                        font.pixelSize: Typography.subtitle
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: "Assesses auto-PEEP"
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.body
                                    }

                                    PrimaryButton {
                                        width: 160
                                        text: "Hold 5 s"
                                        buttonColor: Colors.accentBlue
                                        onClicked: root.recordManeuver("Expiratory hold", root.ventilatorData ? root.ventilatorData.peep : 0, "cmH2O", "Total PEEP")
                                    }
                                }
                            }
                        }

                        Text {
                            text: "Maneuver History"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.subtitle
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: root.maneuverHistory

                            Panel {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 54

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 20

                                    Text {
                                        width: 180
                                        text: modelData.time
                                        color: Colors.textMuted
                                        font.pixelSize: Typography.caption
                                        font.family: Typography.monoFamily
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: 200
                                        text: modelData.type
                                        color: Colors.textPrimary
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.result + " " + modelData.unit
                                        color: Colors.warning
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.notes
                                        color: Colors.textSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
                // -----------------------------------------------------------------
                // TAB 4: Export -- Clinical record CSV export
                // -----------------------------------------------------------------

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 4

                    contentItem: Column {
                        id: exportCol
                        spacing: 16

                        Text {
                            text: "Clinical Record Export"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.subtitle
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            text: "Exports up to 500 recent parameter snapshots "
                                  + "or audit events as CSV files."
                            color: Colors.textSecondary
                            font.pixelSize: Typography.body
                            wrapMode: Text.WordWrap
                        }

                        Row {
                            spacing: 16

                            PrimaryButton {
                                width: 220
                                text: "Export Parameters"
                                buttonColor: Colors.accentBlue
                                onClicked: {
                                    var p = root.databaseData
                                    ? root.databaseData.exportClinicalSummary()
                                    : ""
                                    root.logAction("Export",
                                                   p.length ? "Exported to " + p
                                                            : "Export failed")
                                }
                            }

                            PrimaryButton {
                                width: 220
                                text: "Export Events + Alarms"
                                buttonColor: Colors.accentBlue
                                onClicked: {
                                    var p = root.databaseData
                                    ? root.databaseData.exportAuditSummary()
                                    : ""
                                    root.logAction("Export",
                                                   p.length ? "Exported to " + p
                                                            : "Export failed")
                                }
                            }
                        }
                    }
                }

                // -----------------------------------------------------------------
                // TAB 5: Reference -- Mode and alarm quick-reference
                // -----------------------------------------------------------------

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 5

                    contentItem: ColumnLayout {
                        spacing: 14

                        StyledTextField {
                            Layout.fillWidth: true
                            placeholderText: "Search modes, alarms, troubleshooting..."
                            text: root.referenceSearch
                            onTextChanged: root.referenceSearch = text
                        }

                        Repeater {
                            model: [
                                ["ASV", "Closed-loop targeting minute ventilation. Verify patient category and IBW."],
                                ["PCV", "Pressure-controlled breaths. Monitor tidal volume and plateau pressure."],
                                ["PRVC", "Pressure-regulated volume targeting. Review delivered pressure and compliance."],
                                ["SIMV", "Mandatory breaths with spontaneous support between. Used for weaning."],
                                ["CPAP", "Continuous positive airway pressure for spontaneous breathing."],
                                ["High pressure", "Check circuit obstruction, secretions, biting, bronchospasm, compliance."],
                                ["Low volume", "Check disconnection, cuff leak, circuit leak, patient effort."],
                                ["Apnea alarm", "Verify patient is breathing. Check sensor position and circuit integrity."]
                            ]

                            Panel {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 68
                                visible: root.referenceSearch.length === 0
                                         || modelData[0].toLowerCase().indexOf(
                                    root.referenceSearch.toLowerCase()) >= 0
                                || modelData[1].toLowerCase().indexOf(
                                    root.referenceSearch.toLowerCase()) >= 0

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 16

                                    Text {
                                        width: 140
                                        text: modelData[0]
                                        color: Colors.accentBlue
                                        font.pixelSize: Typography.body
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        width: parent.width - 156
                                        text: modelData[1]
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.body
                                        wrapMode: Text.WordWrap
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
                // -----------------------------------------------------------------
                // TAB 6: Network -- Connectivity and power management
                // -----------------------------------------------------------------

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 6

                    contentItem: ColumnLayout {
                        spacing: 16

                        RowLayout {

                            Layout.fillWidth: true
                            spacing: 18

                            // Connectivity
                            Panel {
                                Layout.fillWidth: true
                                implicitHeight: netCol.height + 36

                                Column {
                                    id: netCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 18
                                    spacing: 14

                                    Text {
                                        text: "Connectivity"
                                        color: Colors.textPrimary
                                        font.pixelSize: Typography.subtitle
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: root.networkType + "  |  HL7/FHIR: " + (root.remoteConnected ? "Connected" : "Offline")
                                        color: root.remoteConnected ? Colors.successBright : Colors.critical
                                        font.pixelSize: Typography.body
                                    }

                                    PrimaryButton {
                                        width: 160
                                        text: root.remoteConnected ? "Disconnect" : "Connect"
                                        buttonColor: root.remoteConnected
                                                     ? Colors.critical : Colors.success
                                        onClicked: {
                                            root.remoteConnected = !root.remoteConnected
                                            root.saveState("remoteConnected",
                                                           root.remoteConnected)
                                        }
                                    }

                                    RowLayout {
                                        width: parent.width
                                        spacing: 12

                                        Text {
                                            Layout.fillWidth: true
                                            text: "IP Address"
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        StyledTextField {
                                            Layout.preferredWidth: 250
                                            text: root.networkAddress
                                            onEditingFinished: {
                                                root.networkAddress = text
                                                root.saveState("networkAddress", text)
                                            }
                                        }
                                    }

                                    RowLayout {
                                        width: parent.width
                                        spacing: 12

                                        Text {
                                            Layout.fillWidth: true
                                            text: "FHIR URL"
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        StyledTextField {
                                            Layout.preferredWidth: 250
                                            text: root.fhirEndpoint
                                            onEditingFinished: {
                                                root.fhirEndpoint = text
                                                root.saveState("fhirEndpoint", text)
                                            }
                                        }
                                    }
                                }
                            }

                            // Power
                            Panel {
                                Layout.fillWidth: true
                                implicitHeight: netCol.height + 36

                                Column {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 18
                                    spacing: 14

                                    Text {
                                        text: "Power"
                                        color: Colors.textPrimary
                                        font.pixelSize: Typography.subtitle
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: (root.acPower ? "AC Power" : "Battery")
                                              + "  |  " + root.batteryLevel + "%"
                                              + "  |  ~" + Math.round(root.batteryLevel * 1.8) + " min"
                                        color: root.acPower
                                               ? Colors.successBright : Colors.warning
                                        font.pixelSize: Typography.body
                                    }

                                    PrimaryButton {
                                        width: 200
                                        text: root.acPower ? "Simulate Battery" : "Restore AC"
                                        buttonColor: root.acPower
                                                     ? Colors.warning : Colors.success
                                        onClicked: {
                                            root.acPower = !root.acPower
                                            root.saveState("acPower", root.acPower)
                                            if (root.acPower) {
                                                root.batteryLevel = 100
                                                root.saveState("batteryLevel", 100)
                                                if (root.appSettingsData)
                                                    root.appSettingsData.dayNightMode = "Automatic"
                                            }
                                            root.evaluateBattery()
                                        }
                                    }

                                    Text {
                                        text: "Night Mode Schedule"
                                        color: Colors.textMuted
                                        font.pixelSize: Typography.caption
                                    }

                                    Row {
                                        spacing: 12

                                        Text {
                                            text: "Night at"
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledSpinBox {
                                            from: 0
                                            to: 23
                                            value: root.appSettingsData ? root.appSettingsData.nightStartHour : 20
                                            onValueModified: { if (root.appSettingsData) root.appSettingsData.nightStartHour = value }
                                        }

                                        Text {
                                            text: "Day at"
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledSpinBox {
                                            from: 0
                                            to: 23
                                            value: root.appSettingsData ? root.appSettingsData.dayStartHour : 6
                                            onValueModified: { if (root.appSettingsData) root.appSettingsData.dayStartHour = value }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                // -----------------------------------------------------------------
                // TAB 7: Maintenance -- Scheduled tasks and history
                // -----------------------------------------------------------------

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 7

                    contentItem: ColumnLayout {
                        spacing: 14

                        Repeater {
                            model: root.maintenanceSchedules

                            Panel {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: maintCol.height + 36

                                Column {
                                    id: maintCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 18
                                    spacing: 10

                                    Text {
                                        text: modelData.item
                                        color: Colors.textPrimary
                                        font.pixelSize: Typography.subtitle
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: (new Date(modelData.dueDate) < new Date() && !modelData.acknowledged ? "OVERDUE  |  " : "") + "Due " + modelData.dueDate
                                        color: new Date(modelData.dueDate) < new Date() && !modelData.acknowledged ? Colors.critical : Colors.textSecondary
                                        font.pixelSize: Typography.body
                                    }

                                    Row {
                                        spacing: 14

                                        StyledTextField {
                                            width: 200
                                            text: modelData.dueDate
                                            placeholderText: "YYYY-MM-DD"
                                            onEditingFinished: {
                                                if (root.databaseData) {
                                                    root.databaseData.saveMaintenanceSchedule(modelData.item, text, modelData.acknowledged)
                                                    root.refreshHistories()
                                                }
                                            }
                                        }

                                        PrimaryButton {
                                            width: 160
                                            text: modelData.acknowledged ? "Reopen" : "Acknowledge"
                                            buttonColor: modelData.acknowledged ? Colors.warning : Colors.success
                                            onClicked: {
                                                if (root.databaseData) {
                                                    root.databaseData.saveMaintenanceSchedule(modelData.item, modelData.dueDate, !modelData.acknowledged)
                                                    root.databaseData.recordMaintenance(modelData.item, modelData.acknowledged ? "Reopened" : "Acknowledged")
                                                    root.refreshHistories()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            text: "Maintenance History"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.subtitle
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: root.maintenanceHistory

                            Panel {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 54

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 20

                                    Text {
                                        width: 180
                                        text: modelData.time
                                        color: Colors.textMuted
                                        font.pixelSize: Typography.caption
                                        font.family: Typography.monoFamily
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: 220
                                        text: modelData.item
                                        color: Colors.textPrimary
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.action
                                        color: Colors.textSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
                // -----------------------------------------------------------------
                // TAB 8: Central -- Multi-bed monitoring overview
                // -----------------------------------------------------------------

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 8

                    contentItem: GridLayout {
                        columns: 2
                        columnSpacing: 16
                        rowSpacing: 16

                        Repeater {
                            model: [
                                {
                                    bed: root.patientData ? root.patientData.bedNumber : "---",
                                    patientId: root.patientData ? root.patientData.patientId : "---",
                                    spo2: root.ventilatorData ? root.ventilatorData.spo2 : 0,
                                    ppeak: root.ventilatorData ? root.ventilatorData.ppeak : 0,
                                    status: "Live"
                                }
                            ].concat(root.centralPatients)

                            Panel {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 120

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: modelData.bed + "    " + modelData.patientId
                                        color: Colors.textPrimary
                                        font.pixelSize: Typography.label
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: "SpO2 " + modelData.spo2
                                              + "%    Ppeak " + modelData.ppeak
                                              + " cmH2O"
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.small
                                    }

                                    Text {
                                        text: modelData.status
                                        color: modelData.status === "Alarm"
                                               ? Colors.critical
                                               : Colors.successBright
                                        font.pixelSize: Typography.small
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }
                    }
                }

                // Status message
                Text {
                    Layout.fillWidth: true
                    visible: root.actionMessage.length > 0
                    text: root.actionMessage
                    color: Colors.successBright
                    font.pixelSize: Typography.body
                    wrapMode: Text.WordWrap
                }

                Item {
                    width: 1
                    height: 20
                }
            }
        }
    }
}
