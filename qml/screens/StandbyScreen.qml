pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"
import "../components/buttons"
import "../components/charts"

Item {
    id: root
    property var patientData
    property var ventilatorData
    signal startRequested()
    signal setupRequested()

    Row {
        anchors.fill: parent
        spacing: Spacing.panelGap

        Panel {
            id: mainPanel
            width: parent.width * 0.76
            height: parent.height
            clip: true

            Rectangle {
                id: standbyBanner
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 28
                height: Math.max(150, parent.height * 0.23)
                radius: Radius.medium
                color: "#276CB8"
                clip: true

                Column {
                    anchors.centerIn: parent
                    width: parent.width - 48
                    spacing: 14

                    Text {
                        width: parent.width
                        text: "00:05:10"
                        color: Colors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Courier New"
                        font.pixelSize: Math.max(34, Math.min(56, standbyBanner.height * 0.28))
                        font.bold: true
                        minimumPixelSize: 28
                        fontSizeMode: Text.Fit
                    }

                    Text {
                        width: parent.width
                        text: "No ventilation delivered to the patient.\nDeactivate humidifier during standby."
                        color: Colors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Courier New"
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
                anchors.margins: 28
                anchors.topMargin: 24
                anchors.bottomMargin: 20
                radius: Radius.small
                color: "transparent"
                border.color: "#95A1B7"
                border.width: 2
                clip: true

                Row {
                    id: categoryTabs
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 70

                    Repeater {
                        model: ["Neonatal", "Adult/ped.", "Last patient"]
                        Rectangle {
                            id: categoryTabDelegate
                            required property int index
                            required property string modelData

                            width: categoryTabs.width / 3
                            height: categoryTabs.height
                            color: (root.patientData.category === "Neonatal" && categoryTabDelegate.index === 0)
                                   || (root.patientData.category !== "Neonatal" && categoryTabDelegate.index === 1)
                                   ? "#18C889" : "#079B66"
                            border.color: "#08714E"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                width: parent.width - 24
                                text: categoryTabDelegate.modelData
                                color: Colors.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: "Courier New"
                                font.pixelSize: 26
                                font.bold: true
                                minimumPixelSize: 18
                                fontSizeMode: Text.Fit
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (categoryTabDelegate.index === 0)
                                        root.patientData.category = "Neonatal"
                                    else
                                        root.patientData.category = "Adult"
                                }
                            }
                        }
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: categoryTabs.bottom
                    anchors.bottom: parent.bottom
                    anchors.margins: 26
                    spacing: 28
                    clip: true

                    Column {
                        width: parent.width * 0.32
                        spacing: 20

                        Repeater {
                        model: ["Adult/ped. 1", "Adult/ped. 2", "Adult/ped. 2"]
                        Rectangle {
                            id: profileDelegate
                            required property string modelData

                            width: parent.width
                                height: Math.max(58, Math.min(76, patientFrame.height * 0.15))
                                radius: 7
                                color: "#A9B0BA"
                                clip: true

                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - 20
                                    text: profileDelegate.modelData
                                    color: Colors.textPrimary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Courier New"
                                    font.pixelSize: 24
                                    minimumPixelSize: 16
                                    fontSizeMode: Text.Fit
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width * 0.36
                        spacing: 22

                        Row {
                            width: parent.width
                            height: 76
                            spacing: 18

                            Text {
                                width: 54
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.patientData.gender === "Male" ? "\u2642" : "\u2640"
                                color: Colors.textPrimary
                                font.pixelSize: 48
                                horizontalAlignment: Text.AlignHCenter
                            }

                            PrimaryButton {
                                width: Math.min(185, (parent.width - 54 - 36) / 2)
                                height: parent.height
                                text: "Male"
                                buttonColor: root.patientData.gender === "Male" ? Colors.accentBlue : "#236AB2"
                                onClicked: root.patientData.gender = "Male"
                            }

                            PrimaryButton {
                                width: Math.min(185, (parent.width - 54 - 36) / 2)
                                height: parent.height
                                text: "Female"
                                buttonColor: root.patientData.gender === "Female" ? Colors.accentBlue : "#236AB2"
                                onClicked: root.patientData.gender = "Female"
                            }
                        }

                        CircularKnob {
                            width: parent.width
                            height: Math.max(180, Math.min(230, patientFrame.height * 0.42))
                            label: "Pat. height"
                            value: root.patientData.height
                            minimum: 40
                            maximum: 220
                            unit: "cm"
                            onValueChangedByUser: function(newValue) { root.patientData.height = newValue }
                        }
                    }

                    Column {
                        width: parent.width * 0.24
                        spacing: 12

                        Text {
                            width: parent.width
                            text: "Pat. height"
                            color: Colors.textPrimary
                            font.family: "Courier New"
                            font.pixelSize: 24
                            font.bold: true
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            width: parent.width
                            text: root.patientData.gender + "\nIBW: " + root.patientData.ibw + " kg"
                            color: Colors.textSecondary
                            font.family: "Courier New"
                            font.pixelSize: 22
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
                anchors.margins: 28
                spacing: 24
                height: 78

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

        Panel {
            width: parent.width * 0.24 - Spacing.panelGap
            height: parent.height
            clip: true

            Flickable {
                id: settingsRail
                anchors.fill: parent
                anchors.margins: 24
                contentWidth: width
                contentHeight: railColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Column {
                    id: railColumn
                    width: settingsRail.width
                    spacing: 22

                    PrimaryButton {
                        width: Math.min(170, parent.width)
                        text: "Freeze"
                        buttonColor: Colors.accentBlue
                    }

                    CircularKnob {
                        width: parent.width
                        height: 182
                        label: "Oxygen"
                        value: root.ventilatorData.fio2
                        unit: "%"
                        onValueChangedByUser: function(newValue) { root.ventilatorData.fio2 = newValue }
                    }

                    CircularKnob {
                        width: parent.width
                        height: 182
                        label: "PEEP C/PAP"
                        value: root.ventilatorData.peep
                        maximum: 30
                        unit: "cmH2O"
                        onValueChangedByUser: function(newValue) { root.ventilatorData.peep = newValue }
                    }

                    CircularKnob {
                        width: parent.width
                        height: 182
                        label: "%MinVol"
                        value: root.ventilatorData.minuteVolume
                        maximum: 400
                        unit: "%"
                        onValueChangedByUser: function(newValue) { root.ventilatorData.minuteVolume = newValue }
                    }
                }
            }
        }
    }
}
