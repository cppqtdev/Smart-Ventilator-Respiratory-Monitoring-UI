pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: ControlsScreen.qml
// Description: Parameter controls organized in five tabbed sections
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../styles"
import "../components/cards"
import "../components/charts"
import "../components/buttons"

Control {
    id: root
    property var ventilatorData
    property var patientData
    property int currentSection: 0

    function loadSectionScreen(sectionScreen, index) {
        root.currentSection = index
        mainLoader.sourceComponent = sectionScreen
    }

    contentItem: RowLayout {
        spacing: Spacing.panelGap

        // Left sidebar: section tabs
        Control {
            Layout.preferredWidth: root.width * 0.22
            Layout.fillHeight: true

            contentItem: ColumnLayout {
                spacing: 16

                PrefsTabButton {
                    Layout.fillWidth: true
                    checked: root.currentSection === 0
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Basic"
                    onClicked: root.loadSectionScreen(basicPage, 0)
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    checked: root.currentSection === 1
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Patient"
                    onClicked: root.loadSectionScreen(patientPage, 1)
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    checked: root.currentSection === 2
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Advanced"
                    onClicked: root.loadSectionScreen(advancedPage, 2)
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    checked: root.currentSection === 3
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Alarm Limits"
                    onClicked: root.loadSectionScreen(alarmLimitsPage, 3)
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    checked: root.currentSection === 4
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Apnea Backup"
                    onClicked: root.loadSectionScreen(apneaBackupPage, 4)
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        // Right panel: section content
        Panel {
            id: rightPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: controlsGridLayout.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                Control {
                    width: rightPanel.width
                    padding: 24

                    contentItem: ColumnLayout {
                        id: controlsGridLayout

                        Loader {
                            id: mainLoader
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            sourceComponent: basicPage
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // -----------------------------------------------------------------
    // Basic: core ventilation parameters
    // -----------------------------------------------------------------
    Component {
        id: basicPage
        Grid {
            columns: 3
            spacing: 28

            PressureGroupBox {
                labelText: "FiO2"
                value: root.ventilatorData.fio2
                unit: "%"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("fio2", v)
                }
            }
            PressureGroupBox {
                labelText: "PEEP"
                value: root.ventilatorData.peep
                maximumValue: 30
                unit: "cmH2O"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("peep", v)
                }
            }
            PressureGroupBox {
                labelText: "Pressure Support"
                value: root.ventilatorData.pressureSupport
                maximumValue: 40
                unit: "cmH2O"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("pressureSupport", v)
                }
            }
            PressureGroupBox {
                labelText: "Resp. Rate"
                value: root.ventilatorData.respiratoryRate
                maximumValue: 60
                unit: "1/min"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("respiratoryRate", v)
                }
            }
            PressureGroupBox {
                labelText: "Trigger"
                value: root.ventilatorData.trigger
                maximumValue: 10
                unit: "L/min"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("trigger", v)
                }
            }
            PressureGroupBox {
                labelText: "Tidal Volume"
                value: root.ventilatorData.tidalVolume
                maximumValue: 900
                unit: "mL"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("tidalVolume", v)
                }
            }
            PressureGroupBox {
                labelText: "%MinVol"
                value: root.ventilatorData.minuteVolume
                maximumValue: 400
                unit: "%"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("minuteVolume", v)
                }
            }
        }
    }

    // -----------------------------------------------------------------
    // Patient: profile, ventilation timer, demographics
    // -----------------------------------------------------------------
    Component {
        id: patientPage
        Row {
            spacing: 34
            clip: true

            Column {
                width: parent.width * 0.3
                spacing: 22

                PrimaryButton {
                    width: parent.width
                    text: "Basic"
                    buttonColor: Colors.success
                    onClicked: root.loadSectionScreen(basicPage, 0)
                }
                PrimaryButton {
                    width: parent.width
                    text: "Patient"
                    buttonColor: Colors.successDark
                    onClicked: {}
                }
                Text {
                    width: parent.width
                    text: "Ventilation\nTime"
                    color: Colors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Typography.monoFamily
                    font.pixelSize: Typography.subtitleLarge
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    text: root.ventilatorData.ventilationTime
                    color: Colors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Typography.monoFamily
                    font.pixelSize: Typography.headline
                    font.weight: Font.DemiBold
                }
                PrimaryButton {
                    width: parent.width * 0.62
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Save Profile"
                    buttonColor: Colors.accentBlue
                    onClicked: root.patientData.saveProfile()
                }
            }

            Control {
                width: parent.width * 0.64
                clip: true
                padding: Spacing.panelGap

                background: Rectangle {
                    radius: Radius.small
                    color: Colors.background
                }

                contentItem: Column {
                    spacing: 22

                    PressureGroupBox {
                        anchors.horizontalCenter: parent.horizontalCenter
                        labelText: "Pat. height"
                        value: root.patientData.height
                        minimumValue: 40
                        maximumValue: 220
                        unit: "cm"
                        onValueChangedByUser: function(v) {
                            root.patientData.height = v
                        }
                    }

                    Row {
                        width: parent.width
                        height: 66
                        spacing: 18

                        PrefsTabButton {
                            width: (parent.width - parent.spacing) / 2
                            text: "Male"
                            checked: root.patientData.gender === "Male"
                            font.pixelSize: Typography.label
                            font.weight: Font.DemiBold
                            onClicked: root.patientData.gender = "Male"
                        }

                        PrefsTabButton {
                            width: (parent.width - parent.spacing) / 2
                            text: "Female"
                            checked: root.patientData.gender === "Female"
                            font.pixelSize: Typography.label
                            font.weight: Font.DemiBold
                            onClicked: root.patientData.gender = "Female"
                        }
                    }

                    Text {
                        width: parent.width
                        text: root.patientData.gender
                            + "  |  Height: "
                            + root.patientData.height + " cm"
                            + "  |  IBW: "
                            + root.patientData.ibw + " kg"
                        color: Colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.monoFamily
                        font.pixelSize: Typography.body
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    // -----------------------------------------------------------------
    // Advanced: ramp, pressure limit, ETS, and other advanced params
    // -----------------------------------------------------------------
    Component {
        id: advancedPage
        Grid {
            columns: 3
            spacing: 30

            PressureGroupBox {
                labelText: "P-Ramp"
                value: 60
                unit: "%"
                onValueChangedByUser: function(v) {}
            }
            PressureGroupBox {
                labelText: "Oxygen"
                value: root.ventilatorData.fio2
                unit: "%"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("fio2", v)
                }
            }
            PressureGroupBox {
                labelText: "Pressure Limit"
                value: 35
                maximumValue: 60
                unit: "cmH2O"
                onValueChangedByUser: function(v) {}
            }
            PressureGroupBox {
                labelText: "PEEP C/PAP"
                value: root.ventilatorData.peep
                maximumValue: 30
                unit: "cmH2O"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("peep", v)
                }
            }
            PressureGroupBox {
                labelText: "ETS"
                value: 25
                unit: "%"
                onValueChangedByUser: function(v) {}
            }
            PressureGroupBox {
                labelText: "%MinVol"
                value: root.ventilatorData.minuteVolume
                maximumValue: 400
                unit: "%"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestParameterChange("minuteVolume", v)
                }
            }
        }
    }

    // -----------------------------------------------------------------
    // Alarm Limits: bound to controller alarm threshold properties
    // -----------------------------------------------------------------
    Component {
        id: alarmLimitsPage
        Grid {
            columns: 3
            spacing: 30

            PressureGroupBox {
                labelText: "High Pressure"
                value: root.ventilatorData.alarmHighPressure
                maximumValue: 80
                unit: "cmH2O"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestAlarmLimitChange("highPressure", v)
                }
            }
            PressureGroupBox {
                labelText: "Low Pressure"
                value: root.ventilatorData.alarmLowPressure
                maximumValue: 40
                unit: "cmH2O"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestAlarmLimitChange("lowPressure", v)
                }
            }
            PressureGroupBox {
                labelText: "Apnea Time"
                value: root.ventilatorData.alarmApneaTime
                maximumValue: 60
                unit: "s"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestAlarmLimitChange("apneaTime", v)
                }
            }
            PressureGroupBox {
                labelText: "Low VT"
                value: root.ventilatorData.alarmLowVt
                maximumValue: 900
                unit: "mL"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestAlarmLimitChange("lowVt", v)
                }
            }
            PressureGroupBox {
                labelText: "High MV"
                value: root.ventilatorData.alarmHighMv
                maximumValue: 30
                unit: "L/min"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestAlarmLimitChange("highMv", v)
                }
            }
            PressureGroupBox {
                labelText: "SpO2 Low"
                value: root.ventilatorData.alarmLowSpo2
                maximumValue: 100
                unit: "%"
                onValueChangedByUser: function(v) {
                    root.ventilatorData.requestAlarmLimitChange("lowSpo2", v)
                }
            }
        }
    }

    // -----------------------------------------------------------------
    // Apnea Backup: toggleable backup ventilation configuration
    // -----------------------------------------------------------------
    Component {
        id: apneaBackupPage
        Column {
            spacing: 28

            Text {
                text: "Apnea Backup Ventilation"
                color: Colors.textPrimary
                font.pixelSize: Typography.title
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: "Backup ventilation activates automatically when no "
                    + "spontaneous breathing is detected within the apnea "
                    + "time limit."
                color: Colors.textSecondary
                font.pixelSize: Typography.body
                wrapMode: Text.WordWrap
            }

            Row {
                spacing: 18

                PrimaryButton {
                    width: 200
                    height: 52
                    text: root.ventilatorData.apneaBackupEnabled
                        ? "Backup ON" : "Backup OFF"
                    buttonColor: root.ventilatorData.apneaBackupEnabled
                        ? Colors.success : Colors.critical
                    onClicked: {
                        root.ventilatorData.requestApneaBackupChange(
                            !root.ventilatorData.apneaBackupEnabled)
                    }
                }

                PrimaryButton {
                    width: 200
                    height: 52
                    text: "Mode: " + root.ventilatorData.mode
                    buttonColor: Colors.buttonMuted
                }
            }

            Grid {
                width: parent.width
                columns: 3
                spacing: 22

                PressureGroupBox {
                    labelText: "Backup Rate"
                    value: root.ventilatorData.respiratoryRate
                    maximumValue: 60
                    unit: "1/min"
                    onValueChangedByUser: function(v) {
                        root.ventilatorData.requestParameterChange("respiratoryRate", v)
                    }
                }
                PressureGroupBox {
                    labelText: "Backup VT"
                    value: root.ventilatorData.tidalVolume
                    maximumValue: 900
                    unit: "mL"
                    onValueChangedByUser: function(v) {
                        root.ventilatorData.requestParameterChange("tidalVolume", v)
                    }
                }
                PressureGroupBox {
                    labelText: "Backup PEEP"
                    value: root.ventilatorData.peep
                    maximumValue: 30
                    unit: "cmH2O"
                    onValueChangedByUser: function(v) {
                        root.ventilatorData.requestParameterChange("peep", v)
                    }
                }
            }
        }
    }
}
