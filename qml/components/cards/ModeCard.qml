import QtQuick 2.15
import "../../styles"

Panel {
    property string mode: "VCV"
    property string description: ""
    property string clinicalUse: ""
    property bool selected: false
    signal clicked()
    color: selected ? "#1D5FAE" : Colors.surface
    border.color: selected ? Colors.accentBlue : Colors.line
    border.width: selected ? 3 : 1

    MouseArea { anchors.fill: parent; onClicked: parent.clicked() }

    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
        text: mode
        color: Colors.textPrimary
        font.pixelSize: 34
        font.bold: true
    }
    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 68
        anchors.margins: 20
        text: description + "\n" + clinicalUse
        color: Colors.textSecondary
        font.pixelSize: 19
        wrapMode: Text.WordWrap
        lineHeight: 1.15
    }
}
