pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"

Control {
    id: root
    property var alarmData

    padding: 24

    background: Rectangle {
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
        border.width: 1
    }

    contentItem: Column {
        spacing: 12

        Rectangle {
            width: parent.width
            height: 48
            radius: Radius.small
            color: "#079B66"
            Text { anchors.centerIn: parent; text: "All Events"; color: Colors.textPrimary; font.family: "Courier New"; font.pixelSize: 18; font.bold: true }
        }

        Flickable {
            width: parent.width
            height: parent.height - 76
            contentWidth: width
            contentHeight: eventColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: eventColumn
                width: parent.width

                Repeater {
                    model: [
                        ["13:27:04", "Mode", "Mode --> ASV", "normal"],
                        ["13:27:04", "Parameter", "FiO2 changed to 60%", "normal"],
                        ["13:27:04", "Parameter", "PEEP changed to 15 cmH2O", "normal"],
                        ["13:27:04", "Alarm", "High Minute Volume", "critical"],
                        ["13:27:04", "Alarm", "CT Low", "warning"],
                        ["13:27:04", "System", "Sensor simulation started", "normal"],
                        ["13:27:04", "Mode", "Mode --> SIMV", "normal"]
                    ]
                    Rectangle {
                        id: eventRow
                        required property var modelData
                        width: parent.width
                        height: 58
                        color: modelData[3] === "critical" ? Colors.critical
                             : modelData[3] === "warning" ? Colors.warning
                             : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 24
                            anchors.rightMargin: 24
                            spacing: 30
                            Text { width: 150; anchors.verticalCenter: parent.verticalCenter; text: eventRow.modelData[0]; color: Colors.textPrimary; font.family: "Courier New"; font.pixelSize: 22 }
                            Text { width: 170; anchors.verticalCenter: parent.verticalCenter; text: eventRow.modelData[1]; color: Colors.textPrimary; font.family: "Courier New"; font.pixelSize: 22 }
                            Text { width: parent.width - 390; anchors.verticalCenter: parent.verticalCenter; text: eventRow.modelData[2]; color: Colors.textPrimary; font.family: "Courier New"; font.pixelSize: 22; elide: Text.ElideRight }
                        }
                    }
                }
            }
        }
    }
}
