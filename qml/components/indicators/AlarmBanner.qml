import QtQuick 2.15
import "../../styles"

Rectangle {
    property string headline: ""
    property string detail: ""
    radius: Radius.medium
    color: Colors.warning
    clip: true

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height * 0.55
        color: Colors.critical
        Text {
            anchors.centerIn: parent
            text: headline
            color: Colors.textPrimary
            font.pixelSize: Math.max(22, parent.height * 0.42)
            font.bold: true
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        text: detail
        color: Colors.textPrimary
        font.pixelSize: Math.max(20, parent.height * 0.25)
        font.bold: true
    }
}
