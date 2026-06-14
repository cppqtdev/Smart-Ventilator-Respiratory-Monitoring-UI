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

    readonly property var sections: ["Basic", "Patient", "Advanced", "Alarm Limits", "Apnea Backup"]

    function loadSectionScreen(sectionScreen) {
        mainLoader.sourceComponent = sectionScreen
    }

    contentItem: RowLayout {
        spacing: Spacing.panelGap

        Control {
            Layout.preferredWidth: root.width * 0.22
            Layout.fillHeight: true

            contentItem: ColumnLayout {
                spacing: 16

                PrefsTabButton {
                    Layout.fillWidth: true
                    checked: true
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Basic"
                    onClicked: loadSectionScreen(basicPage)
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Patient"
                    onClicked: loadSectionScreen(patientPage)
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Advanced"
                    onClicked: loadSectionScreen(advancedPage)
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Alarm Limits"
                    onClicked: loadSectionScreen(alarmLimitsPage)
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    bgColor: checked ? Colors.success : Colors.disabled
                    text: "Apnea Backup"
                    onClicked: loadSectionScreen(apneaBackupPage)
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Panel {
            id: rightPannel
            width: root.width * 0.78 - Spacing.panelGap
            height: root.height
            clip: true

            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: controlsGridLayout.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Control {
                    width: rightPannel.width
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

    Component {
        id: basicPage
        Grid {
            columns: 3
            spacing: 28
            property real cellWidth: (width - spacing * 2) / 3
            property real cellHeight: Math.max(180, cellWidth * 0.52)

            PressureGroupBox {
                labelText: "FiO2"
                value: root.ventilatorData.fio2
                unit: "%"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.fio2 = newValue
                }
            }
            PressureGroupBox {
                labelText: "PEEP"
                value: root.ventilatorData.peep
                maximumValue: 30
                unit: "cmH2O"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.peep = newValue
                }
            }
            PressureGroupBox {
                labelText: "Pressure Support"
                value: root.ventilatorData.pressureSupport
                maximumValue: 40
                unit: "cmH2O"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.pressureSupport = newValue
                }
            }
            PressureGroupBox {
                labelText: "Resp. Rate"
                value: root.ventilatorData.respiratoryRate
                maximumValue: 60
                unit: "1/min"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.respiratoryRate = newValue
                }
            }
            PressureGroupBox {
                labelText: "Trigger"
                value: root.ventilatorData.trigger
                maximumValue: 10
                unit: "L/min"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.trigger = newValue
                }
            }
            PressureGroupBox {
                labelText: "Tidal Volume"
                value: root.ventilatorData.tidalVolume
                maximumValue: 900
                unit: "mL"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.tidalVolume = newValue
                }
            }
            PressureGroupBox {
                labelText: "%MinVol"
                value: root.ventilatorData.minuteVolume
                maximumValue: 400
                unit: "%"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.minuteVolume = newValue
                }
            }
        }
    }

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
                }
                PrimaryButton {
                    width: parent.width
                    text: "Patient"
                    buttonColor: Colors.successDark
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
                    text: "Reset"
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
                        labelText: "Pat. height";
                        value: root.patientData.height; minimumValue: 40;
                        maximumValue: 220; unit: "cm";
                        onValueChangedByUser: function(newValue) { root.patientData.height = newValue }
                    }

                    Row {
                        width: parent.width
                        height: 66
                        spacing: 18

                        PrefsTabButton {
                            width: (parent.width - parent.spacing) / 2;
                            text: "Male";
                            checked: true
                            font.pixelSize: Typography.label
                            font.weight: Font.DemiBold
                            onClicked: root.patientData.gender = "Male"
                        }

                        PrefsTabButton {
                            width: (parent.width - parent.spacing) / 2;
                            text: "Female";
                            font.pixelSize: Typography.label
                            font.weight: Font.DemiBold
                            onClicked: root.patientData.gender = "Female"
                        }
                    }

                    Text {
                        width: parent.width
                        text: "Pat. height\n" + root.patientData.gender + "\nIBW: " + root.patientData.ibw + " kg"
                        color: Colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.monoFamily
                        font.pixelSize: Typography.bodyLarge
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    Component {
        id: advancedPage
        Grid {
            columns: 3
            spacing: 30
            property real cellWidth: (width - spacing * 2) / 3
            property real cellHeight: Math.max(178, height / 3 - spacing)
            PressureGroupBox {
                labelText: "P-Ramp"
                value: 60
                unit: "%"
            }
            PressureGroupBox {
                labelText: "Oxygen"
                value: root.ventilatorData.fio2
                unit: "%"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.fio2 = newValue
                }
            }
            PressureGroupBox {
                labelText: "Pressure Limit"
                value: 35
                maximumValue: 60
                unit: "cmH2O"
            }
            PressureGroupBox {
                labelText: "PEEP C/PAP"
                value: root.ventilatorData.peep
                maximumValue: 30
                unit: "cmH2O"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.peep = newValue
                }
            }
            PressureGroupBox {
                labelText: "ETS"
                value: 25
                unit: "%"
            }
            PressureGroupBox {
                labelText: "%MinVol"
                value: root.ventilatorData.minuteVolume
                maximumValue: 400
                unit: "%"
                onValueChangedByUser: function(newValue) {
                    root.ventilatorData.minuteVolume = newValue
                }
            }
        }
    }

    Component {
        id: alarmLimitsPage
        Grid {
            columns: 3
            spacing: 30
            property real cellWidth: (width - spacing * 2) / 3
            property real cellHeight: Math.max(178, height / 3 - spacing)
            PressureGroupBox {
                labelText: "High Pressure"
                value: 40
                maximumValue: 80
                unit: "cmH2O"
            }
            PressureGroupBox {
                labelText: "Low Pressure"
                value: 5
                maximumValue: 40
                unit: "cmH2O"
            }
            PressureGroupBox {
                labelText: "Apnea Time"
                value: 20
                maximumValue: 60
                unit: "s"
            }
            PressureGroupBox {
                labelText: "Low VT"
                value: 300
                maximumValue: 900
                unit: "mL"
            }
            PressureGroupBox {
                labelText: "High MV"
                value: 12
                maximumValue: 30
                unit: "L/min"
            }
            PressureGroupBox {
                labelText: "SpO2 Low"
                value: 90
                maximumValue: 100
                unit: "%"
            }
        }
    }

    Component {
        id: apneaBackupPage
        Column {
            spacing: 28

            Text {
                text: "Apnea Backup"
                color: Colors.textPrimary
                font.pixelSize: Typography.title
                font.weight: Font.DemiBold
            }

            Grid {
                width: parent.width
                columns: 3
                spacing: 22

                Repeater {
                    model: ["Backup ON", "Mode SIMV", "Rate 20/min", "VT 420 mL", "PEEP 15", "Oxygen 60%"]

                    PrimaryButton {
                        id: backupButton
                        required property string modelData
                        width: (parent.width - 44) / 3
                        font.pixelSize: Typography.label
                        height: 48
                        text: backupButton.modelData
                        buttonColor: Colors.buttonMuted
                    }

                }
            }
        }
    }
}
