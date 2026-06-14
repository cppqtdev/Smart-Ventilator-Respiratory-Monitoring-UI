// -----------------------------------------------------------------------
// File: ModeCard.qml
// Description: Ventilation mode selection card with description
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import "../../styles"

Panel {
    property string mode: "VCV"
    property string description: ""
    property string clinicalUse: ""
    property bool selected: false
    signal clicked()
    color: selected ? Colors.accentBlueSelected : Colors.surface
    border.color: selected ? Colors.accentBlue : Colors.line
    border.width: selected ? 3 : 1

    MouseArea { anchors.fill: parent; onClicked: parent.clicked() }

    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
        text: mode
        color: Colors.textPrimary
        font.pixelSize: Typography.titleLarge
        font.weight: Font.DemiBold
    }
    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 68
        anchors.margins: 20
        text: description + "\n" + clinicalUse
        color: Colors.textSecondary
        font.pixelSize: Typography.label
        wrapMode: Text.WordWrap
        lineHeight: 1.15
    }
}
