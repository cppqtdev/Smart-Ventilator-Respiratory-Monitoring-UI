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
    property int layoutPreset: 1

    // Layout presets control waveform visibility:
    // 1 = Standard (Paw only in main area)
    // 2 = Dual (Paw + Flow)
    // 3 = Triple (Paw + Flow + Volume)
    // 4 = Quad (Paw + Flow + Volume + CO2)
    // 5 = Full (all waveforms + lung + params)

    // Patient disconnect / circuit occlusion banner
    Rectangle {
        id: disconnectBanner
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.ventilatorData
            && (root.ventilatorData.patientDisconnected
                || root.ventilatorData.circuitOcclusion) ? 48 : 0
        visible: height > 0
        color: Colors.critical
        z: 10

        SequentialAnimation on opacity {
            running: disconnectBanner.visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 300 }
            NumberAnimation { to: 1.0; duration: 300 }
        }

        Text {
            anchors.centerIn: parent
            text: root.ventilatorData
                && root.ventilatorData.patientDisconnected
                ? "PATIENT DISCONNECT -- Check circuit and patient connection"
                : "CIRCUIT OCCLUSION -- Check tubing and filters for obstruction"
            color: Colors.textPrimary
            font.pixelSize: Typography.body
            font.weight: Font.DemiBold
        }

        Behavior on height {
            NumberAnimation { duration: 200 }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.topMargin: disconnectBanner.height
        // HARDWARE: All metric values and waveforms in this screen are bound
        // to VentilatorController properties. To integrate real sensors,
        // replace the simulation in VentilatorController.updateSimulation()
        // with hardware driver reads. No QML changes required.
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
                highValue: root.ventilatorData.alarmHighPressure
                lowValue: root.ventilatorData.alarmLowPressure
                state: root.ventilatorData.ppeak
                    > root.ventilatorData.alarmHighPressure
                    ? "critical" : "normal"
            }
            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "ExpMinVol"
                value: root.ventilatorData.expMinVol
                unit: "L/min"
                highValue: root.ventilatorData.alarmHighMv
                lowValue: "1.0"
                state: root.ventilatorData.expMinVol
                    > root.ventilatorData.alarmHighMv
                    ? "warning" : "normal"
            }
            MetricTile {
                width: parent.width
                height: parent.tileHeight
                label: "VTE"
                value: root.ventilatorData.vte
                unit: "mL"
                highValue: "839"
                lowValue: root.ventilatorData.alarmLowVt
                state: root.ventilatorData.vte
                    < root.ventilatorData.alarmLowVt
                    ? "warning" : "normal"
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
                highValue: root.ventilatorData.alarmHighMv * 10
                state: root.ventilatorData.minuteVolume
                    > root.ventilatorData.alarmHighMv * 10
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

                        // Waveform height adapts to share available space
                        property int visibleWaveforms:
                            (root.layoutPreset >= 1 ? 1 : 0)
                            + (root.layoutPreset >= 2 ? 1 : 0)
                            + (root.layoutPreset >= 3 ? 1 : 0)
                            + (root.layoutPreset >= 4 ? 1 : 0)
                        property real waveHeight: Math.max(
                            100,
                            waveformFlickable.height * 0.20
                                / Math.max(1, visibleWaveforms)
                                * visibleWaveforms)

                        WaveformChart {
                            width: parent.width
                            height: waveformColumn.waveHeight
                            title: "Pressure Paw"
                            traceColor: Colors.success
                            samples: root.ventilatorData.pressureWaveform
                            frozen: root.ventilatorData.frozen
                            minimumValue: 0
                            maximumValue: 45
                            unit: "cmH2O"
                        }
                        WaveformChart {
                            visible: root.layoutPreset >= 2
                            width: parent.width
                            height: visible ? waveformColumn.waveHeight : 0
                            title: "Flow"
                            traceColor: Colors.magenta
                            samples: root.ventilatorData.flowWaveform
                            frozen: root.ventilatorData.frozen
                            minimumValue: -85
                            maximumValue: 85
                            unit: "L/min"
                        }
                        WaveformChart {
                            visible: root.layoutPreset >= 3
                            width: parent.width
                            height: visible ? waveformColumn.waveHeight : 0
                            title: "Volume"
                            traceColor: Colors.warning
                            samples: root.ventilatorData.volumeWaveform
                            frozen: root.ventilatorData.frozen
                            minimumValue: 0
                            maximumValue: 900
                            unit: "mL"
                        }
                        WaveformChart {
                            visible: root.layoutPreset >= 4
                            width: parent.width
                            height: visible ? waveformColumn.waveHeight : 0
                            title: "PCO2"
                            traceColor: Colors.accentBlue
                            samples: root.ventilatorData.co2Waveform
                            frozen: root.ventilatorData.frozen
                            minimumValue: 0
                            maximumValue: 50
                            unit: "mmHg"
                        }
                        // Compact parameter grid
                        Row {
                            width: parent.width
                            height: 56
                            spacing: 12

                            Repeater {
                                model: [
                                    { lbl: "Pconf", val: root.ventilatorData.pressureSupport, u: "cmH2O" },
                                    { lbl: "I:E", val: root.ventilatorData.ieRatio, u: "" },
                                    { lbl: "Pdriv", val: Math.round(root.ventilatorData.drivingPressure), u: "cmH2O" },
                                    { lbl: "Rate", val: root.ventilatorData.respiratoryRate, u: "1/min" }
                                ]

                                Control {
                                    required property var modelData
                                    width: (parent.width - 3 * 12) / 4
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
                            height: 56
                            spacing: 12

                            Repeater {
                                model: [
                                    { lbl: "PetCO2", val: root.ventilatorData.etco2, u: "mmHg" },
                                    { lbl: "Cstat", val: root.ventilatorData.compliance, u: "mL/cmH2O" },
                                    { lbl: "WOB", val: root.ventilatorData.workOfBreathing, u: "J/L" },
                                    { lbl: "Vd/Vt", val: root.ventilatorData.deadSpaceFraction, u: "" }
                                ]

                                Control {
                                    required property var modelData
                                    width: (parent.width - 3 * 12) / 4
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
                                    state: root.ventilatorData.etco2 > 50
                                        ? "warning" : "normal"
                                }
                                MetricTile {
                                    width: (parent.width - 14) / 2
                                    height: (parent.height - 14) / 2
                                    label: "SpO2"
                                    value: root.ventilatorData.spo2
                                    unit: "%"
                                    state: root.ventilatorData.spo2 > 0
                                        && root.ventilatorData.spo2
                                            < root.ventilatorData.alarmLowSpo2
                                        ? "critical" : "normal"
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
