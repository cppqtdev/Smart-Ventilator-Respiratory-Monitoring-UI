pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: ModeSelectionScreen.qml
// Description: Grid of eight ventilation mode selection cards
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../styles"
import "../components/cards"
import "../components/buttons"

Control {
    id: root
    property var ventilatorData
    signal modeConfirmed()

    padding: 0
    bottomPadding: 24

    contentItem: Column {
        spacing: Spacing.panelGap
        Text {
            text: "Ventilation Mode Selection"
            color: Colors.textPrimary
            font.pixelSize: Typography.titleLarge
            font.weight: Font.DemiBold
        }

        Grid {
            width: parent.width
            height: parent.height - 120
            columns: 4
            spacing: 18
            Repeater {
                model: [
                    ["VCV", "Volume controlled breaths.", "Use for stable compliance."],
                    ["PCV", "Pressure controlled breaths.", "Use when limiting peak pressure."],
                    ["SIMV", "Mandatory plus spontaneous support.", "Use during weaning."],
                    ["CPAP", "Continuous positive pressure.", "Use for spontaneous breathing."],
                    ["BiPAP", "Two pressure levels.", "Use for non-invasive support."],
                    ["ASV", "Adaptive support ventilation.", "Use for closed-loop demo mode."],
                    ["PRVC", "Pressure regulated volume control.", "Use to target Vt with pressure limit."],
                    ["PSV", "Patient-triggered pressure support.", "Use for assisted spontaneous breaths."]
                ]
                ModeCard {
                    id: modeDelegate
                    required property var modelData
                    width: (parent.width - 54) / 4
                    height: (parent.height - 18) / 2
                    mode: modeDelegate.modelData[0]
                    description: modeDelegate.modelData[1]
                    clinicalUse: modeDelegate.modelData[2]
                    selected: root.ventilatorData.mode === mode
                    onClicked: root.ventilatorData.mode = mode
                }
            }
        }

        PrimaryButton {
            width: Math.min(360, parent.width * 0.3)
            text: "Confirm Mode & Start"
            buttonColor: Colors.success
            onClicked: root.modeConfirmed()
        }
    }
}
