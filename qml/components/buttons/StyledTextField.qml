// -----------------------------------------------------------------------
// File: StyledTextField.qml
// Description: Themed text input field matching the ventilator UI design
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic
import "../../styles"

TextField {
    id: control
    leftPadding: 14
    rightPadding: 14
    color: Colors.textPrimary
    placeholderTextColor: Colors.textMuted
    font.pixelSize: Typography.label

    background: Rectangle {
        implicitHeight: 48
        radius: Radius.small
        color: Colors.background
        border.color: control.activeFocus ? Colors.accentBlue : Colors.line
        border.width: control.activeFocus ? 2 : 1
    }
}
