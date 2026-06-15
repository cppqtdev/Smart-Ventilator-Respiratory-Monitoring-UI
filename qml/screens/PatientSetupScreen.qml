pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: PatientSetupScreen.qml
// Description: Patient profile configuration with age, height, weight sliders
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"
import "../components/buttons"

Item {
    id: root
    property var patientData
    signal continueRequested()

    Row {
        anchors.fill: parent
        spacing: Spacing.panelGap

        Panel {
            width: parent.width * 0.58
            height: parent.height
            Column {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 18
                Text {
                    text: "Patient Profile Configuration"
                    color: Colors.textPrimary
                    font.pixelSize: Typography.titleLarge
                    font.weight: Font.DemiBold
                }
                Repeater {
                    model: [
                        { label: "Age", prop: "age", min: 0, max: 120, unit: "years" },
                        { label: "Height", prop: "height", min: 40, max: 220, unit: "cm" },
                        { label: "Weight", prop: "weight", min: 1, max: 220, unit: "kg" }
                    ]
                    Row {
                        id: sliderRow
                        required property var modelData
                        width: parent.width
                        height: 84
                        spacing: 20
                        Text {
                            width: 180
                            anchors.verticalCenter: parent.verticalCenter
                            text: sliderRow.modelData.label
                            color: Colors.textPrimary
                            font.pixelSize: Typography.subtitle
                            font.weight: Font.DemiBold
                        }
                        StyledSlider {
                            width: parent.width - 440
                            anchors.verticalCenter: parent.verticalCenter
                            from: sliderRow.modelData.min
                            to: sliderRow.modelData.max
                            stepSize: 1
                            snapMode: Slider.SnapAlways
                            value: root.patientData[sliderRow.modelData.prop]
                            onMoved: root.patientData[sliderRow.modelData.prop] = Math.round(value)
                        }
                        Text {
                            property int currentVal: root.patientData[sliderRow.modelData.prop]
                            property bool atLimit: currentVal <= sliderRow.modelData.min
                                || currentVal >= sliderRow.modelData.max
                            width: 210
                            anchors.verticalCenter: parent.verticalCenter
                            text: currentVal + " " + sliderRow.modelData.unit
                            color: atLimit ? Colors.warning : Colors.textPrimary
                            font.pixelSize: Typography.subtitleLarge
                            font.weight: Font.DemiBold
                        }
                    }
                }
                Row {
                    spacing: 18
                    PrimaryButton {
                        width: 180
                        text: "Adult"
                        buttonColor: patientData.category === "Adult"
                                     ? Colors.accentBlue : Colors.disabled
                        onClicked: patientData.category = "Adult"
                    }
                    PrimaryButton {
                        width: 180
                        text: "Pediatric"
                        buttonColor: patientData.category === "Pediatric"
                                     ? Colors.accentBlue : Colors.disabled
                        onClicked: patientData.category = "Pediatric"
                    }
                    PrimaryButton {
                        width: 180
                        text: "Neonatal"
                        buttonColor: patientData.category === "Neonatal"
                                     ? Colors.accentBlue : Colors.disabled
                        onClicked: patientData.category = "Neonatal"
                    }
                }
                Row {
                    spacing: 18
                    PrimaryButton {
                        width: 180
                        text: "Male"
                        buttonColor: patientData.gender === "Male"
                                     ? Colors.accentBlue : Colors.disabled
                        onClicked: patientData.gender = "Male"
                    }
                    PrimaryButton {
                        width: 180
                        text: "Female"
                        buttonColor: patientData.gender === "Female"
                                     ? Colors.accentBlue : Colors.disabled
                        onClicked: patientData.gender = "Female"
                    }
                }
            }
        }

        Panel {
            width: parent.width * 0.42 - Spacing.panelGap
            height: parent.height
            clip: true

            Flickable {
                id: suggestedFlickable
                anchors.fill: parent
                anchors.margins: 28
                contentWidth: width
                contentHeight: suggestedColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Column {
                    id: suggestedColumn
                    width: suggestedFlickable.width
                    spacing: 20
                    Text {
                        width: parent.width
                        text: "Suggested Settings"
                        color: Colors.textPrimary
                        font.pixelSize: Typography.title
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                    }
                    MetricTile {
                        width: parent.width
                        height: 118
                        label: "Predicted Body Weight"
                        value: patientData.ibw
                        unit: "kg"
                    }
                    MetricTile {
                        width: parent.width
                        height: 118
                        label: "Tidal Volume"
                        value: patientData.recommendedVt
                        unit: "mL"
                    }
                    MetricTile {
                        width: parent.width
                        height: 118
                        label: "Respiratory Rate"
                        value: patientData.recommendedRate
                        unit: "1/min"
                    }
                    Text {
                        width: parent.width
                        text: "Auto-calculated values update as age, height, weight, gender, or category changes."
                        color: Colors.textSecondary
                        font.pixelSize: Typography.label
                        wrapMode: Text.WordWrap
                    }
                    PrimaryButton {
                        width: parent.width
                        text: "Continue to Modes"
                        onClicked: {
                            root.patientData.saveProfile()
                            root.continueRequested()
                        }
                    }
                }
            }
        }
    }
}
