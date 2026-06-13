import QtQuick 2.15
import QtQuick.Controls.Basic
import "../../styles"

Button {
    id: root
    property color buttonColor: Colors.success
    height: Spacing.touch
    font.pixelSize: 24
    font.bold: true
    background: Rectangle {
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
