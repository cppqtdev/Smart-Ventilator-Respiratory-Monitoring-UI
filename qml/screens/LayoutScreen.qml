pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: LayoutScreen.qml
// Description: Behance-style lung visualization monitoring layout
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
    property var patientData
    property var ventilatorData
    property var appSettingsData

    RowLayout {
        spacing: Spacing.panelGap
        anchors.fill: parent

        ColumnLayout {
            Layout.preferredWidth: root.width * 0.22
            Layout.fillHeight: true
            spacing: 12

            MetricTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                label: "Ppeak"
                value: root.ventilatorData.ppeak
                unit: "cmH2O"
                highValue: root.ventilatorData.alarmHighPressure
                lowValue: root.ventilatorData.alarmLowPressure
                state: root.ventilatorData.ppeak > root.ventilatorData.alarmHighPressure ? "critical" : "normal"
            }
            MetricTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                label: "Pplat"
                value: root.ventilatorData.pplat
                unit: "cmH2O"
            }
            MetricTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                label: "Pmean"
                value: root.ventilatorData.pmean
                unit: "cmH2O"
            }
            MetricTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                label: "PEEP"
                value: root.ventilatorData.peep
                unit: "cmH2O"
            }
            MetricTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                label: "Minute Vol"
                value: root.ventilatorData.minuteVolume
                unit: "%"
                highValue: root.ventilatorData.alarmHighMv * 10
                state: root.ventilatorData.minuteVolume > root.ventilatorData.alarmHighMv * 10 ? "critical" : "normal"
            }
        }

        Control {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            padding: 24

            background: Rectangle {
                radius: Radius.medium
                color: Colors.surface
                border.color: Colors.line
                border.width: 1
            }

            contentItem: ColumnLayout {

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.patientData.gender + "\n"
                              + root.patientData.height + " cm\nIBW: "
                              + root.patientData.ibw + " kg"
                        color: Colors.textSecondary
                        font.pixelSize: Math.max(18, Math.min(24, parent.height * 0.035))
                        lineHeight: 1.25
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "PVI\n------\n%"
                        color: Colors.textSecondary
                        font.pixelSize: Math.max(18, Math.min(24, parent.height * 0.035))
                        horizontalAlignment: Text.AlignRight
                        lineHeight: 1.25
                    }
                }

                Image {
                    id: lungImage
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(parent.width * 0.68, parent.height * 0.78)
                    Layout.preferredHeight: width * 0.92
                    source: "qrc:/qml/assets/icons/lungs.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.ventilatorData.running ? 0.96 : 0.72

                    SequentialAnimation on scale {
                        running: root.ventilatorData.running && !root.ventilatorData.frozen
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.025; duration: 950; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 950; easing.type: Easing.InOutSine }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Row {
                    id: bottomMetricsRow
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                    spacing: 12

                    Repeater {
                        model: [
                            { label: "Pcuff", value: root.ventilatorData.pressureSupport, unit: "cmH2O" },
                            { label: "Pulse", value: root.ventilatorData.respiratoryRate, unit: "1/min" },
                            { label: "Rinsp", value: root.ventilatorData.resistance, unit: "cmH2O/s" },
                            { label: "SpO2", value: root.ventilatorData.spo2, unit: "%" },
                            { label: "Cstat", value: root.ventilatorData.compliance, unit: "cmH2O" },
                            { label: "PetCO2", value: root.ventilatorData.etco2, unit: "mmHg" }
                        ]

                        Column {
                            id: metricDelegate
                            required property var modelData
                            width: (bottomMetricsRow.width - bottomMetricsRow.spacing * 5) / 6
                            spacing: 2

                            Text {
                                width: parent.width
                                text: metricDelegate.modelData.label
                                color: Colors.textPrimary
                                font.family: "Courier New"
                                font.pixelSize: Math.max(16, Math.min(24, root.height * 0.03))
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: metricDelegate.modelData.value
                                color: metricDelegate.modelData.label === "PetCO2" ? Colors.accentBlue : Colors.textPrimary
                                font.family: "Courier New"
                                font.pixelSize: Math.max(28, Math.min(42, root.height * 0.05))
                                font.bold: true
                                minimumPixelSize: 20
                                fontSizeMode: Text.Fit
                            }

                            Text {
                                width: parent.width
                                text: metricDelegate.modelData.unit
                                color: Colors.textPrimary
                                font.pixelSize: Math.max(13, Math.min(18, root.height * 0.022))
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        Panel {
            Layout.preferredWidth: root.width * 0.215 - Spacing.panelGap * 2
            Layout.fillHeight: true
            clip: true

            Flickable {
                id: controlRail
                anchors.fill: parent
                contentWidth: width
                contentHeight: railColumn.height + 48
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Column {
                    id: railColumn
                    width: controlRail.width - 48
                    x: 24
                    y: 24
                    spacing: 20

                    PrimaryButton {
                        width: Math.min(170, parent.width)
                        text: root.ventilatorData.frozen ? "Resume" : "Freeze"
                        buttonColor: Colors.accentBlue
                        onClicked: root.ventilatorData.toggleFreeze()
                    }

                    PressureGroupBox {
                        width: parent.width
                        height: Math.max(170, controlRail.height * 0.24)
                        labelText: "Oxygen"
                        value: root.ventilatorData.fio2
                        unit: "%"
                        onValueChangedByUser: function(newValue) {
                            root.ventilatorData.fio2 = newValue
                        }
                    }

                    PressureGroupBox {
                        width: parent.width
                        height: Math.max(170, controlRail.height * 0.24)
                        labelText: "PEEP C/PAP"
                        value: root.ventilatorData.peep
                        maximumValue: 30
                        unit: "cmH2O"
                        onValueChangedByUser: function(newValue) {
                            root.ventilatorData.requestParameterChange("peep", newValue)
                        }
                    }

                    PressureGroupBox {
                        width: parent.width
                        height: Math.max(170, controlRail.height * 0.24)
                        labelText: "%MinVol"
                        value: root.ventilatorData.minuteVolume
                        maximumValue: 400
                        unit: "%"
                        onValueChangedByUser: function(newValue) {
                            root.ventilatorData.requestParameterChange("minuteVolume", newValue)
                        }
                    }
                }
            }
        }
    }
}
