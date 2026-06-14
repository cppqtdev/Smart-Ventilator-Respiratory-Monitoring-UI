// -----------------------------------------------------------------------
// File: TargetScreen.qml
// Description: Target parameter settings for ventilation goals
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

    contentItem: RowLayout {
        spacing: Spacing.panelGap

        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: targetContent.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                Control {
                    width: parent.width
                    padding: 24

                    contentItem: Column {
                        id: targetContent
                        spacing: 24

                        Text {
                            text: "Target Parameters"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.title
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            text: "Set target values for the ventilator to maintain. "
                                + "The controller will adjust delivery parameters "
                                + "to achieve these targets."
                            color: Colors.textSecondary
                            font.pixelSize: Typography.body
                            wrapMode: Text.WordWrap
                            lineHeight: 1.3
                        }

                        Grid {
                            width: parent.width
                            columns: 3
                            spacing: 28

                            PressureGroupBox {
                                labelText: "Target Vt"
                                value: root.ventilatorData
                                    ? root.ventilatorData.tidalVolume : 420
                                maximumValue: 900
                                unit: "mL"
                                onValueChangedByUser: function(v) {
                                    root.ventilatorData.tidalVolume = v
                                }
                            }
                            PressureGroupBox {
                                labelText: "Target Rate"
                                value: root.ventilatorData
                                    ? root.ventilatorData.respiratoryRate : 20
                                maximumValue: 60
                                unit: "1/min"
                                onValueChangedByUser: function(v) {
                                    root.ventilatorData.respiratoryRate = v
                                }
                            }
                            PressureGroupBox {
                                labelText: "Target FiO2"
                                value: root.ventilatorData
                                    ? root.ventilatorData.fio2 : 60
                                unit: "%"
                                onValueChangedByUser: function(v) {
                                    root.ventilatorData.fio2 = v
                                }
                            }
                            PressureGroupBox {
                                labelText: "Target PEEP"
                                value: root.ventilatorData
                                    ? root.ventilatorData.peep : 15
                                maximumValue: 30
                                unit: "cmH2O"
                                onValueChangedByUser: function(v) {
                                    root.ventilatorData.peep = v
                                }
                            }
                            PressureGroupBox {
                                labelText: "Target PS"
                                value: root.ventilatorData
                                    ? root.ventilatorData.pressureSupport : 12
                                maximumValue: 40
                                unit: "cmH2O"
                                onValueChangedByUser: function(v) {
                                    root.ventilatorData.pressureSupport = v
                                }
                            }
                            PressureGroupBox {
                                labelText: "Target %MV"
                                value: root.ventilatorData
                                    ? root.ventilatorData.minuteVolume : 110
                                maximumValue: 400
                                unit: "%"
                                onValueChangedByUser: function(v) {
                                    root.ventilatorData.minuteVolume = v
                                }
                            }
                        }
                    }
                }
            }
        }

        // Current achieved values panel
        Panel {
            Layout.preferredWidth: parent.width * 0.28
            Layout.fillHeight: true

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                Text {
                    text: "Achieved"
                    color: Colors.textSecondary
                    font.pixelSize: Typography.subtitle
                    font.weight: Font.DemiBold
                }

                MetricTile {
                    width: parent.width
                    height: 90
                    label: "VTE"
                    value: root.ventilatorData
                        ? root.ventilatorData.vte : 0
                    unit: "mL"
                }
                MetricTile {
                    width: parent.width
                    height: 90
                    label: "Ftotal"
                    value: root.ventilatorData
                        ? root.ventilatorData.ftotal : 0
                    unit: "b/min"
                }
                MetricTile {
                    width: parent.width
                    height: 90
                    label: "ExpMinVol"
                    value: root.ventilatorData
                        ? root.ventilatorData.expMinVol : 0
                    unit: "L/min"
                }
                MetricTile {
                    width: parent.width
                    height: 90
                    label: "SpO2"
                    value: root.ventilatorData
                        ? root.ventilatorData.spo2 : 0
                    unit: "%"
                }
            }
        }
    }
}
