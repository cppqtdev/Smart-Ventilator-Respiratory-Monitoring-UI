import QtQuick 2.15
import "../styles"
import "../components/cards"
import "../components/buttons"

Item {
    property var ventilatorData
    signal modeConfirmed()

    Column {
        anchors.fill: parent
        spacing: Spacing.panelGap
        Text { text: "Ventilation Mode Selection"; color: Colors.textPrimary; font.pixelSize: 34; font.bold: true }
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
                    width: (parent.width - 54) / 4
                    height: (parent.height - 18) / 2
                    mode: modelData[0]
                    description: modelData[1]
                    clinicalUse: modelData[2]
                    selected: ventilatorData.mode === mode
                    onClicked: ventilatorData.mode = mode
                }
            }
        }
        PrimaryButton {
            width: 360
            text: "Confirm Mode & Start"
            onClicked: modeConfirmed()
        }
    }
}
