// -----------------------------------------------------------------------
// File: MonitoringScreen.qml
// Description: Active monitoring with real-time waveforms, metrics, and lung visualization
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
    property var alarmData

    RowLayout {
        anchors.fill: parent
        spacing: Spacing.panelGap

        Column {
            Layout.preferredWidth: parent.width * 0.22
            Layout.fillHeight: true

            spacing: 12
            property real tileHeight: (height - spacing * 6) / 7

            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "Ppeak"
                value: root.ventilatorData.ppeak
                unit: "cmH2O"
                highValue: "40"
                lowValue: "5"
                state: root.ventilatorData.ppeak > root.ventilatorData.alarmHighPressure
                    ? "critical" : "normal"
            }
            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "ExpMinVol"
                value: root.ventilatorData.expMinVol
                unit: "L/min"
                highValue: "19.9"
                lowValue: "10.0"
            }
            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "VTE"
                value: root.ventilatorData.vte
                unit: "mL"
                highValue: "839"
                lowValue: "288"
            }
            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "Ftotal"
                value: root.ventilatorData.ftotal
                unit: "b/min"
                highValue: "40"
                lowValue: "8"
            }
            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "RCexp"
                value: root.ventilatorData.rcexp
                unit: "s"
                highValue: "5"
                lowValue: "0"
            }
            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "PEEP"
                value: root.ventilatorData.peep
                unit: "cmH2O"
            }
            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "Minute Vol"
                value: root.ventilatorData.minuteVolume
                unit: "%"
                state: root.ventilatorData.minuteVolume > 145
                    ? "critical" : "normal"
            }
        }

        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Flickable {
                id: waveformFlickable
                anchors.fill: parent
                contentWidth: width
                contentHeight: waveformColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Control {
                    padding: 24
                    width: waveformFlickable.width

                    contentItem: Column {
                        id: waveformColumn
                        spacing: 16

                        WaveformChart {
                            width: parent.width
                            height: Math.max(130, waveformFlickable.height * 0.20)
                            title: "Pressure Paw"
                            traceColor: Colors.success
                            samples: root.ventilatorData.pressureWaveform
                            minimumValue: 0
                            maximumValue: 45
                        }
                        WaveformChart {
                            width: parent.width
                            height: Math.max(130, waveformFlickable.height * 0.20)
                            title: "Flow"
                            traceColor: Colors.magenta
                            samples: root.ventilatorData.flowWaveform
                            minimumValue: -85
                            maximumValue: 85
                        }
                        WaveformChart {
                            width: parent.width
                            height: Math.max(130, waveformFlickable.height * 0.20)
                            title: "Volume"
                            traceColor: Colors.warning
                            samples: root.ventilatorData.volumeWaveform
                            minimumValue: 0
                            maximumValue: 90
                        }
                        WaveformChart {
                            width: parent.width
                            height: Math.max(130, waveformFlickable.height * 0.20)
                            title: "PCO2"
                            traceColor: Colors.accentBlue
                            samples: root.ventilatorData.co2Waveform
                            minimumValue: 0
                            maximumValue: 50
                        }
                        // Compact parameter grid per Behance design
                        Row {
                            width: parent.width
                            height: 56
                            spacing: 12

                            Repeater {
                                model: [
                                    { lbl: "Pconf", val: root.ventilatorData.pressureSupport, u: "cmH2O" },
                                    { lbl: "Rate", val: root.ventilatorData.respiratoryRate, u: "1/min" },
                                    { lbl: "PetCO2", val: root.ventilatorData.etco2, u: "mmHg" },
                                    { lbl: "Cstat", val: root.ventilatorData.compliance, u: "mL/cmH2O" }
                                ]

                                Control {
                                    required property var modelData
                                    width: (parent.width - 36) / 4
                                    height: parent.height
                                    leftPadding: 18
                                    rightPadding: 18

                                    background: Rectangle {
                                        radius: Radius.medium
                                        color: "#00000000"
                                        border.color: Colors.line
                                        border.width: 1
                                    }

                                    contentItem: RowLayout {
                                        spacing: 8

                                        Text {
                                            text: modelData.lbl
                                            color: Colors.textSecondary
                                            font.pixelSize: Typography.caption
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: modelData.val
                                            color: Colors.textPrimary
                                            font.pixelSize: Typography.body
                                            font.weight: Font.DemiBold
                                        }

                                        Text {
                                            text: modelData.u
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            height: Math.max(170, waveformFlickable.height * 0.26)
                            spacing: 20
                            Grid {
                                width: parent.width * 0.48
                                height: parent.height
                                columns: 2
                                spacing: 14
                                MetricTile {
                                    width: (parent.width - 14) / 2
                                    height: (parent.height - 14) / 2
                                    label: "EtCO2"
                                    value: root.ventilatorData.etco2
                                    unit: "mmHg"
                                }
                                MetricTile {
                                    width: (parent.width - 14) / 2
                                    height: (parent.height - 14) / 2
                                    label: "SpO2"
                                    value: root.ventilatorData.spo2
                                    unit: "%"
                                }
                                MetricTile {
                                    width: (parent.width - 14) / 2
                                    height: (parent.height - 14) / 2
                                    label: "Cstat"
                                    value: root.ventilatorData.compliance
                                    unit: "mL/cmH2O"
                                }
                                MetricTile {
                                    width: (parent.width - 14) / 2
                                    height: (parent.height - 14) / 2
                                    label: "Rinsp"
                                    value: root.ventilatorData.resistance
                                    unit: "cmH2O/s"
                                }
                            }

                            Panel {
                                width: parent.width * 0.50
                                height: parent.height

                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 50
                                    source: "qrc:/qml/assets/icons/lungs.png"
                                    sourceSize: Qt.size(150, 300/0.92077)
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 22
                                    text: root.patientData.gender + "\n"
                                          + root.patientData.height + " cm\nIBW: "
                                          + root.patientData.ibw + " kg"
                                    color: Colors.textSecondary
                                    font.pixelSize: Typography.bodyLarge
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: 20
                        }
                    }
                }
            }
        }

        Panel {
            Layout.preferredWidth: parent.width * 0.215 - Spacing.panelGap * 2
            Layout.fillHeight: true
            clip: true

            Flickable {
                id: monitoringKnobFlickable
                anchors.fill: parent
                contentWidth: width
                contentHeight: knobColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Control {
                    width: monitoringKnobFlickable.width
                    padding: 24

                    contentItem: Column {
                        id: knobColumn
                        spacing: 18

                        PrefsTabButton {
                            width: Math.min(170, parent.width)
                            text: root.ventilatorData.frozen ? "Resume" : "Freeze"
                            onClicked: root.ventilatorData.toggleFreeze()
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
                            labelText: "PEEP C/PAP"
                            value: root.ventilatorData.peep
                            maximumValue: 30
                            unit: "cmH2O"
                            onValueChangedByUser: function(newValue) {
                                root.ventilatorData.peep = newValue
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

                        Item {
                            width: Math.min(170, parent.width)
                            height: 5
                        }
                    }
                }
            }
        }
    }
}
