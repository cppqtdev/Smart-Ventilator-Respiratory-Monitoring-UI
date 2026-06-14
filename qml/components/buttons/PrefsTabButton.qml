// -----------------------------------------------------------------------
// File: PrefsTabButton.qml
// Description: Toggle-style tab selection button
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic
import "../../styles"

TabButton {
    id: control
    font.family: Typography.monoFamily
    font.pixelSize: Typography.label
    font.bold: Font.DemiBold

    property color bgColor: checked ? Colors.accentBlue : Colors.disabled

    background: Rectangle {
        implicitHeight: 48
        implicitWidth: 154
        radius: Radius.small
        color: control.bgColor
        opacity: enabled ? 1 : 0.55
    }

    contentItem: Text {
        text: control.text
        color: Colors.textPrimary
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
