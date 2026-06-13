import QtQuick 2.15
import "../../styles"

Rectangle {
    id: root
    property string mode: "ASV"
    property string patientCategory: "Adult"
    radius: Radius.medium
    color: Colors.surface
    clip: true

    Row {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 18
        Rectangle {
            width: Math.min(132, parent.width * 0.34)
            height: parent.height
            radius: 8
            color: Colors.disabled
            border.color: Colors.textSecondary
            Text {
                anchors.centerIn: parent
                width: parent.width - 12
                height: parent.height - 8
                text: root.mode + "\nMODE"
                color: Colors.textPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: 26
                minimumPixelSize: 16
                fontSizeMode: Text.Fit
            }
        }
        Text {
            width: 48
            anchors.verticalCenter: parent.verticalCenter
            text: root.patientCategory.charAt(0)
            color: Colors.textPrimary
            font.pixelSize: 38
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            width: 42
            anchors.verticalCenter: parent.verticalCenter
            text: "\u25CF"
            color: Colors.success
            font.pixelSize: 38
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            width: Math.max(70, parent.width - 132 - 48 - 42 - parent.spacing * 3)
            anchors.verticalCenter: parent.verticalCenter
            text: "Circuit"
            color: Colors.textPrimary
            font.pixelSize: 26
            font.bold: true
            elide: Text.ElideRight
            minimumPixelSize: 16
            fontSizeMode: Text.Fit
        }
    }
}
