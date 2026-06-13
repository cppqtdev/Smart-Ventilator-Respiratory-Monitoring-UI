import QtQuick 2.15
import "../../styles"

Panel {
    id: root
    property string label: "Ppeak"
    property string value: "38"
    property string unit: "cmH2O"
    property string state: "normal"
    color: state === "critical" ? Colors.critical : Colors.surface
    clip: true

    Text {
        id: labelText
        anchors.left: parent.left
        anchors.right: valueText.left
        anchors.top: parent.top
        anchors.leftMargin: 18
        anchors.rightMargin: 8
        anchors.topMargin: 16
        text: root.label
        color: Colors.textPrimary
        font.pixelSize: Math.max(16, Math.min(24, parent.height * 0.16))
        font.bold: true
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
    }

    Text {
        id: valueText
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.top: parent.top
        anchors.topMargin: 18
        width: parent.width * 0.42
        text: root.value
        color: Colors.textPrimary
        font.pixelSize: Math.max(28, Math.min(48, parent.height * 0.30))
        font.bold: true
        horizontalAlignment: Text.AlignRight
        minimumPixelSize: 20
        fontSizeMode: Text.Fit
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        width: parent.width * 0.55
        text: root.unit
        color: Colors.textPrimary
        font.pixelSize: Math.max(14, Math.min(20, parent.height * 0.14))
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
    }
}
