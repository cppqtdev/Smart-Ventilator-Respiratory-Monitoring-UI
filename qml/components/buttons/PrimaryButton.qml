// -----------------------------------------------------------------------
// File: PrimaryButton.qml
// Description: Styled action button with configurable color
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic
import "../../styles"

Button {
    id: root
    property color buttonColor: Colors.success

    font.pixelSize: Typography.label
    font.weight: Font.DemiBold
    font.family: Typography.monoFamily

    background: Rectangle {
        implicitHeight: 48
        radius: Radius.small
        color: root.enabled ? root.buttonColor : Colors.disabled
    }

    contentItem: Text {
        text: root.text
        color: Colors.textPrimary
        font: root.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
