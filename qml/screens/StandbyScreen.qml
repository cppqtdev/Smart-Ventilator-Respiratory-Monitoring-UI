pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: StandbyScreen.qml
// Description: Patient selection, gender, presets, and calibration actions
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../styles"
import "../components/cards"
import "../components/buttons"
import "../components/charts"

Item {
    id: root
    property var patientData
    property var ventilatorData
    property int standbySeconds: 0
    signal startRequested()
    signal setupRequested()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.standbySeconds++
    }

    RowLayout {
        anchors.fill: parent
        spacing: Spacing.panelGap

        Control {
            id: mainPanel
            Layout.fillWidth: true
            Layout.fillHeight: true

            background: Rectangle {
                radius: Radius.medium
                color: Colors.surface
                border.color: Colors.line
                border.width: 1
            }

            contentItem: Item {
                clip: true

                Rectangle {
                    id: standbyBanner
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 24
                    height: Math.max(150, parent.height * 0.23)
                    radius: Radius.medium
                    color: Colors.accentBlueMedium
                    clip: true

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 48
                        spacing: 14

                        Text {
                            width: parent.width
                            text: {
                                var h = Math.floor(root.standbySeconds / 3600)
                                var m = Math.floor((root.standbySeconds % 3600) / 60)
                                var s = root.standbySeconds % 60
                                return String(h).padStart(2, '0') + ":" + String(m).padStart(2, '0') + ":" + String(s).padStart(2, '0')
                            }
                            color: Colors.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Typography.monoFamily
                            font.pixelSize: Math.max(34, Math.min(56, standbyBanner.height * 0.28))
                            font.weight: Font.DemiBold
                            minimumPixelSize: 28
                            fontSizeMode: Text.Fit
                        }

                        Text {
                            width: parent.width
                            text: "No ventilation delivered to the patient.\nDeactivate humidifier during standby."
                            color: Colors.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Typography.monoFamily
                            font.pixelSize: Math.max(20, Math.min(30, standbyBanner.height * 0.16))
                            wrapMode: Text.WordWrap
                            lineHeight: 1.1
                        }
                    }
                }

                Rectangle {
                    id: patientFrame
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: standbyBanner.bottom
                    anchors.bottom: actionRow.top
                    anchors.margins: 24
                    radius: Radius.small
                    color: "transparent"
                    border.color: Colors.border
                    border.width: 2
                    clip: true

                    Control {
                        id: categoryTabs
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 70
                        leftPadding: 24
                        rightPadding: 24

                        contentItem: RowLayout {
                            spacing: 10

                            PrefsTabButton {
                                Layout.fillWidth: true
                                text: "Neonatal"
                                checked: true
                                onClicked: {
                                    root.patientData.category = "Neonatal"
                                }
                            }

                            PrefsTabButton {
                                Layout.fillWidth: true
                                text: "Adult/ped."
                                onClicked: {
                                    root.patientData.category = "Adult"
                                }
                            }

                            PrefsTabButton {
                                Layout.fillWidth: true
                                text: "Last patient"
                                onClicked: {
                                    root.patientData.category = "Adult"
                                }
                            }
                        }
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: categoryTabs.bottom
                        anchors.bottom: parent.bottom
                        anchors.margins: 24
                        anchors.bottomMargin: 10
                        anchors.topMargin: 10
                        spacing: 28
                        clip: true

                        Control {
                            width: parent.width * 0.32

                            contentItem: ColumnLayout {
                                spacing: 10

                                PrefsTabButton {
                                    Layout.fillWidth: true
                                    text: "Adult/ped. 1"
                                    bgColor: Colors.buttonInactive
                                    onClicked: { root.patientData.category = "Adult"; root.patientData.loadProfile() }
                                }

                                PrefsTabButton {
                                    Layout.fillWidth: true
                                    text: "Adult/ped. 2"
                                    bgColor: Colors.buttonInactive
                                    onClicked: { root.patientData.category = "Adult"; root.patientData.loadProfile() }
                                }

                                PrefsTabButton {
                                    Layout.fillWidth: true
                                    text: "Neonatal"
                                    bgColor: Colors.buttonInactive
                                    onClicked: { root.patientData.category = "Neonatal"; root.patientData.loadProfile() }
                                }
                            }
                        }

                        Column {
                            width: parent.width * 0.36
                            spacing: 10

                            RowLayout {
                                width: parent.width
                                height: 76
                                spacing: 10

                                Text {
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    text: root.patientData.gender === "Male" ? "\u2642" : "\u2640"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.titleLarge
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                PrefsTabButton {
                                    Layout.fillWidth: true
                                    text: "Male"
                                    bgColor: root.patientData.gender === "Male"
                                             ? Colors.accentBlue : Colors.accentBlueDark
                                    onClicked: root.patientData.gender = "Male"
                                }

                                PrefsTabButton {
                                    Layout.fillWidth: true
                                    text: "Female"
                                    bgColor: root.patientData.gender === "Female"
                                             ? Colors.accentBlue : Colors.accentBlueDark
                                    onClicked: root.patientData.gender = "Female"
                                }
                            }

                            PressureGroupBox {
                                labelText: "Pat. height"
                                value: root.patientData.height
                                minimumValue: 40
                                maximumValue: 220
                                unit: "cm"
                                onValueChangedByUser: function(newValue) { root.patientData.height = newValue }
                            }

                            Item {
                                Layout.preferredHeight: 20
                                Layout.fillWidth: true
                            }
                        }

                        Column {
                            width: parent.width * 0.24
                            spacing: 12

                            Text {
                                width: parent.width
                                text: "Pat. height"
                                color: Colors.textPrimary
                                font.family: Typography.monoFamily
                                font.pixelSize: Typography.body
                                font.weight: Font.DemiBold
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                width: parent.width
                                text: root.patientData.gender + "\nIBW: " + root.patientData.ibw + " kg"
                                color: Colors.textSecondary
                                font.family: Typography.monoFamily
                                font.pixelSize: Typography.label
                                wrapMode: Text.WordWrap
                                lineHeight: 1.25
                            }
                        }
                    }
                }

                Row {
                    id: actionRow
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 24
                    spacing: 24
                    height: 56

                    PrimaryButton {
                        width: Math.min(450, mainPanel.width * 0.32)
                        height: parent.height
                        text: "Test & Calib"
                        onClicked: root.setupRequested()
                    }

                    PrimaryButton {
                        width: Math.min(450, mainPanel.width * 0.32)
                        height: parent.height
                        text: "Start Ventilation"
                        onClicked: root.startRequested()
                    }
                }
            }
        }

        Panel {
            Layout.preferredWidth: parent.width * 0.215 - Spacing.panelGap * 2
            Layout.fillHeight: true
            clip: true

            Flickable {
                id: settingsRail
                anchors.fill: parent
                contentWidth: width
                contentHeight: railColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Control {
                    width: settingsRail.width
                    padding: 24

                    contentItem: Column {
                        id: railColumn
                        spacing: 20

                        PrefsTabButton {
                            width: Math.min(170, parent.width)
                            text: root.ventilatorData.frozen ? "Freeze" : "Resume"
                            onToggled: root.ventilatorData.toggleFreeze()
                        }

                        PressureGroupBox {
                            labelText: "Oxygen"
                            value: root.ventilatorData.fio2
                            unit: "%"
                            onValueChangedByUser: function(newValue) { root.ventilatorData.fio2 = newValue }
                        }

                        PressureGroupBox {
                            labelText: "PEEP C/PAP"
                            value: root.ventilatorData.peep
                            maximumValue: 30
                            unit: "cmH2O"
                            onValueChangedByUser: function(newValue) { root.ventilatorData.peep = newValue }
                        }

                        PressureGroupBox {
                            labelText: "%MinVol"
                            value: root.ventilatorData.minuteVolume
                            maximumValue: 400
                            unit: "%"
                            onValueChangedByUser: function(newValue) { root.ventilatorData.minuteVolume = newValue }
                        }

                        Item {
                            width: parent.width
                            height: 20
                        }
                    }
                }
            }
        }
    }
}
