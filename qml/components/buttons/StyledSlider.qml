// -----------------------------------------------------------------------
// File: StyledSlider.qml
// Description: Themed slider matching the ventilator UI design
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic
import "../../styles"

Slider {
    id: control
    height: 40

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 6
        width: control.availableWidth
        height: implicitHeight
        radius: 3
        color: Colors.track

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: Colors.accentBlue
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition
            * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 24
        implicitHeight: 24
        radius: 12
        color: control.pressed
            ? Colors.accentBlue : Colors.textValue
        border.color: Colors.accentBlue
        border.width: 2
    }
}
