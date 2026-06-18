import QtQuick
import QtQuick.Controls.Basic
import "../cards"
import "../buttons"
import "../charts"

Panel {
    id: root

    property var ventilatorData

    clip: true

    Flickable {
        id: railFlickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: knobColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Control {
            width: railFlickable.width
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
                        root.ventilatorData.requestParameterChange("peep", newValue)
                    }
                }
                PressureGroupBox {
                    labelText: "%MinVol target"
                    value: root.ventilatorData.minuteVolume
                    maximumValue: 400
                    unit: "%"
                    onValueChangedByUser: function(newValue) {
                        root.ventilatorData.requestParameterChange("minuteVolume", newValue)
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
