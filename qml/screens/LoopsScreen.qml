// -----------------------------------------------------------------------
// File: LoopsScreen.qml
// Description: Pressure-volume and flow-volume respiratory mechanics loops
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../styles"
import "../components/charts"
import "../components/buttons"

Page {
    id: root
    property var ventilatorData

    background: Rectangle {
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
    }

    header: Control {
        padding: 20
        contentItem: RowLayout {
            Text {
                text: "Respiratory Loops"
                color: Colors.textPrimary
                font.pixelSize: Typography.title
                font.weight: Font.DemiBold
            }
            Text {
                text: "Real-time lung mechanics"
                color: Colors.textMuted
                font.pixelSize: Typography.label
            }
            Item { Layout.fillWidth: true }
            PrimaryButton {
                width: 130
                height: 42
                text: root.ventilatorData && root.ventilatorData.frozen
                    ? "Resume" : "Freeze"
                buttonColor: root.ventilatorData && root.ventilatorData.frozen
                    ? Colors.warning : Colors.accentBlue
                onClicked: {
                    if (root.ventilatorData)
                        root.ventilatorData.toggleFreeze()
                }
            }
        }
    }

    contentItem: RowLayout {
        spacing: 16

        LoopChart {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Pressure - Volume"
            xLabel: "Volume (mL)"
            yLabel: "Pressure (cmH2O)"
            xSamples: root.ventilatorData
                ? root.ventilatorData.volumeWaveform : []
            ySamples: root.ventilatorData
                ? root.ventilatorData.pressureWaveform : []
            xMinimum: 0
            xMaximum: 900
            yMinimum: 0
            yMaximum: 60
            traceColor: Colors.cyan
        }

        LoopChart {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Flow - Volume"
            xLabel: "Volume (mL)"
            yLabel: "Flow (L/min)"
            xSamples: root.ventilatorData
                ? root.ventilatorData.volumeWaveform : []
            ySamples: root.ventilatorData
                ? root.ventilatorData.flowWaveform : []
            xMinimum: 0
            xMaximum: 900
            yMinimum: -80
            yMaximum: 80
            traceColor: Colors.magenta
        }
    }
}
