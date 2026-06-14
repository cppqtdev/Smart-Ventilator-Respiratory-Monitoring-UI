import QtQuick 2.15
import QtQuick.Controls.Basic
import "../../styles"

TabButton {
    id: control
    font.family: "Courier New"
    font.pixelSize: 18
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
