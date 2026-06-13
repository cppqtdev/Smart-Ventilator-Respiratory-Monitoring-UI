pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"
import "../components/charts"
import "../components/buttons"

Item {
    id: root
    property var ventilatorData
    property var patientData
    property int currentSection: 0

    readonly property var sections: ["Basic", "Patient", "Advanced", "Alarm Limits", "Apnea Backup"]

    Row {
        anchors.fill: parent
        spacing: Spacing.panelGap

        Column {
            width: parent.width * 0.22
            height: parent.height
            spacing: 16

            Repeater {
                model: root.sections
                PrimaryButton {
                    id: sectionButton
                    required property int index
                    required property string modelData
                    width: parent.width
                    height: Math.max(56, Math.min(72, root.height * 0.09))
                    text: sectionButton.modelData
                    buttonColor: root.currentSection === sectionButton.index ? Colors.success : "#0B9D69"
                    onClicked: root.currentSection = sectionButton.index
                }
            }
        }

        Panel {
            width: parent.width * 0.78 - Spacing.panelGap
            height: parent.height
            clip: true

            Loader {
                anchors.fill: parent
                anchors.margins: 26
                sourceComponent: root.currentSection === 0 ? basicPage
                               : root.currentSection === 1 ? patientPage
                               : root.currentSection === 2 ? advancedPage
                               : root.currentSection === 3 ? alarmLimitsPage
                               : apneaBackupPage
            }
        }
    }

    Component {
        id: basicPage
        Flickable {
            contentWidth: width
            contentHeight: controlsGrid.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Grid {
                id: controlsGrid
                width: parent.width
                columns: 3
                spacing: 28
                property real cellWidth: (width - spacing * 2) / 3
                property real cellHeight: Math.max(180, cellWidth * 0.52)

                CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "FiO2"; value: root.ventilatorData.fio2; unit: "%"; onValueChangedByUser: function(newValue) { root.ventilatorData.fio2 = newValue } }
                CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "PEEP"; value: root.ventilatorData.peep; maximum: 30; unit: "cmH2O"; onValueChangedByUser: function(newValue) { root.ventilatorData.peep = newValue } }
                CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Pressure Support"; value: root.ventilatorData.pressureSupport; maximum: 40; unit: "cmH2O"; onValueChangedByUser: function(newValue) { root.ventilatorData.pressureSupport = newValue } }
                CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Resp. Rate"; value: root.ventilatorData.respiratoryRate; maximum: 60; unit: "1/min"; onValueChangedByUser: function(newValue) { root.ventilatorData.respiratoryRate = newValue } }
                CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Trigger"; value: root.ventilatorData.trigger; maximum: 10; unit: "L/min"; onValueChangedByUser: function(newValue) { root.ventilatorData.trigger = newValue } }
                CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Tidal Volume"; value: root.ventilatorData.tidalVolume; maximum: 900; unit: "mL"; onValueChangedByUser: function(newValue) { root.ventilatorData.tidalVolume = newValue } }
                CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "%MinVol"; value: root.ventilatorData.minuteVolume; maximum: 400; unit: "%"; onValueChangedByUser: function(newValue) { root.ventilatorData.minuteVolume = newValue } }
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
                PrimaryButton { width: parent.width; text: "Basic"; buttonColor: Colors.success }
                PrimaryButton { width: parent.width; text: "Patient"; buttonColor: "#0B9D69" }
                Text { width: parent.width; text: "Ventilation\nTime"; color: Colors.textPrimary; horizontalAlignment: Text.AlignHCenter; font.family: "Courier New"; font.pixelSize: 28; font.bold: true; wrapMode: Text.WordWrap }
                Text { width: parent.width; text: "0:0:D"; color: Colors.textPrimary; horizontalAlignment: Text.AlignHCenter; font.family: "Courier New"; font.pixelSize: 42; font.bold: true }
                PrimaryButton { width: parent.width * 0.62; anchors.horizontalCenter: parent.horizontalCenter; text: "Reset" }
            }

            Rectangle {
                width: parent.width * 0.64
                height: parent.height
                radius: Radius.small
                color: "#59647C"
                clip: true

                Column {
                    anchors.centerIn: parent
                    width: parent.width * 0.68
                    spacing: 22
                    CircularKnob { width: parent.width; height: 190; label: "Pat. height"; value: root.patientData.height; minimum: 40; maximum: 220; unit: "cm"; onValueChangedByUser: function(newValue) { root.patientData.height = newValue } }
                    Row {
                        width: parent.width
                        height: 66
                        spacing: 18
                        PrimaryButton { width: (parent.width - parent.spacing) / 2; text: "Male"; buttonColor: root.patientData.gender === "Male" ? Colors.accentBlue : "#236AB2"; onClicked: root.patientData.gender = "Male" }
                        PrimaryButton { width: (parent.width - parent.spacing) / 2; text: "Female"; buttonColor: root.patientData.gender === "Female" ? Colors.accentBlue : "#236AB2"; onClicked: root.patientData.gender = "Female" }
                    }
                    Text {
                        width: parent.width
                        text: "Pat. height\n" + root.patientData.gender + "\nIBW: " + root.patientData.ibw + " kg"
                        color: Colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Courier New"
                        font.pixelSize: 22
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
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "P-Ramp"; value: 60; unit: "%" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Oxygen"; value: root.ventilatorData.fio2; unit: "%"; onValueChangedByUser: function(newValue) { root.ventilatorData.fio2 = newValue } }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Pressure Limit"; value: 35; maximum: 60; unit: "cmH2O" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "PEEP C/PAP"; value: root.ventilatorData.peep; maximum: 30; unit: "cmH2O"; onValueChangedByUser: function(newValue) { root.ventilatorData.peep = newValue } }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "ETS"; value: 25; unit: "%" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "%MinVol"; value: root.ventilatorData.minuteVolume; maximum: 400; unit: "%"; onValueChangedByUser: function(newValue) { root.ventilatorData.minuteVolume = newValue } }
        }
    }

    Component {
        id: alarmLimitsPage
        Grid {
            columns: 3
            spacing: 30
            property real cellWidth: (width - spacing * 2) / 3
            property real cellHeight: Math.max(178, height / 3 - spacing)
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "High Pressure"; value: 40; maximum: 80; unit: "cmH2O" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Low Pressure"; value: 5; maximum: 40; unit: "cmH2O" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Apnea Time"; value: 20; maximum: 60; unit: "s" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Low VT"; value: 300; maximum: 900; unit: "mL" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "High MV"; value: 12; maximum: 30; unit: "L/min" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "SpO2 Low"; value: 90; maximum: 100; unit: "%" }
        }
    }

    Component {
        id: apneaBackupPage
        Column {
            spacing: 28
            Text { text: "Apnea Backup"; color: Colors.textPrimary; font.pixelSize: 32; font.bold: true }
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
                        height: 74
                        text: backupButton.modelData
                        buttonColor: "#8F98A6"
                    }
                }
            }
        }
    }
}
