import QtQuick 2.15
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"
import "../components/charts"
import "../components/buttons"

Item {
    id: root
    property var patientData
    property var ventilatorData
    property var alarmData

    Row {
        anchors.fill: parent
        spacing: Spacing.panelGap

        Column {
            width: parent.width * 0.22
            height: parent.height
            spacing: 16
            property real tileHeight: (height - spacing * 4) / 5
            MetricTile { width: parent.width; height: parent.tileHeight; label: "Ppeak"; value: root.ventilatorData.ppeak; unit: "cmH2O"; state: root.ventilatorData.ppeak > 42 ? "critical" : "normal" }
            MetricTile { width: parent.width; height: parent.tileHeight; label: "Pplat"; value: root.ventilatorData.pplat; unit: "cmH2O" }
            MetricTile { width: parent.width; height: parent.tileHeight; label: "Pmean"; value: root.ventilatorData.pmean; unit: "cmH2O" }
            MetricTile { width: parent.width; height: parent.tileHeight; label: "PEEP"; value: root.ventilatorData.peep; unit: "cmH2O" }
            MetricTile { width: parent.width; height: parent.tileHeight; label: "Minute Vol"; value: root.ventilatorData.minuteVolume; unit: "%"; state: root.ventilatorData.minuteVolume > 145 ? "critical" : "normal" }
        }

        Panel {
            width: parent.width * 0.52
            height: parent.height
            clip: true

            Flickable {
                id: waveformFlickable
                anchors.fill: parent
                anchors.margins: 24
                contentWidth: width
                contentHeight: waveformColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: waveformColumn
                width: waveformFlickable.width
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
                Row {
                    width: parent.width
                    height: Math.max(170, waveformFlickable.height * 0.26)
                    spacing: 20
                    Grid {
                        width: parent.width * 0.48
                        height: parent.height
                        columns: 2
                        spacing: 14
                        MetricTile { width: (parent.width - 14) / 2; height: (parent.height - 14) / 2; label: "EtCO2"; value: root.ventilatorData.etco2; unit: "mmHg" }
                        MetricTile { width: (parent.width - 14) / 2; height: (parent.height - 14) / 2; label: "SpO2"; value: root.ventilatorData.spo2; unit: "%" }
                        MetricTile { width: (parent.width - 14) / 2; height: (parent.height - 14) / 2; label: "Cstat"; value: root.ventilatorData.compliance; unit: "mL/cmH2O" }
                        MetricTile { width: (parent.width - 14) / 2; height: (parent.height - 14) / 2; label: "Rinsp"; value: root.ventilatorData.resistance; unit: "cmH2O/s" }
                    }
                    Panel {
                        width: parent.width * 0.50
                        height: parent.height
                        Text { anchors.centerIn: parent; text: "LUNG\nCOMPLIANCE"; color: Colors.textSecondary; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 36; font.bold: true }
                        Text { anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 22; text: root.patientData.gender + "\n" + root.patientData.height + " cm\nIBW: " + root.patientData.ibw + " kg"; color: Colors.textSecondary; font.pixelSize: 22; horizontalAlignment: Text.AlignRight }
                    }
                }
            }
            }
        }

        Panel {
            width: parent.width * 0.26 - Spacing.panelGap * 2
            height: parent.height
            clip: true

            Flickable {
                id: monitoringKnobFlickable
                anchors.fill: parent
                anchors.margins: 20
                contentWidth: width
                contentHeight: knobColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Column {
                    id: knobColumn
                    width: monitoringKnobFlickable.width
                    spacing: 18
                    PrimaryButton { width: Math.min(170, parent.width); text: root.ventilatorData.frozen ? "Resume" : "Freeze"; buttonColor: Colors.accentBlue; onClicked: root.ventilatorData.toggleFreeze() }
                    CircularKnob { width: parent.width; height: 190; label: "Oxygen"; value: root.ventilatorData.fio2; unit: "%"; onValueChangedByUser: function(newValue) { root.ventilatorData.fio2 = newValue } }
                    CircularKnob { width: parent.width; height: 190; label: "PEEP C/PAP"; value: root.ventilatorData.peep; maximum: 30; unit: "cmH2O"; onValueChangedByUser: function(newValue) { root.ventilatorData.peep = newValue } }
                    CircularKnob { width: parent.width; height: 190; label: "%MinVol"; value: root.ventilatorData.minuteVolume; maximum: 400; unit: "%"; onValueChangedByUser: function(newValue) { root.ventilatorData.minuteVolume = newValue } }
                }
            }
        }
    }
}
