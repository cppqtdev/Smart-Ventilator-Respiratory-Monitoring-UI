pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: EventsScreen.qml
// Description: Chronological event timeline for mode changes, parameters, and alarms
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"

Control {
    id: root
    property var alarmData
    property var eventData

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
            color: Colors.successMuted
            Text {
                anchors.centerIn: parent
                text: "All Events"
                color: Colors.textPrimary
                font.family: Typography.monoFamily
                font.pixelSize: Typography.label
                font.weight: Font.DemiBold
            }
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
                    model: root.eventData

                    Rectangle {
                        id: eventRow
                        required property string time
                        required property string source
                        required property string description
                        required property string severity

                        width: parent.width
                        height: 58
                        color: eventRow.severity === "critical"
                            ? Colors.critical
                            : eventRow.severity === "warning"
                                ? Colors.warning
                                : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 24
                            anchors.rightMargin: 24
                            spacing: 30

                            Text {
                                width: 150
                                anchors.verticalCenter: parent.verticalCenter
                                text: eventRow.time
                                color: Colors.textPrimary
                                font.family: Typography.monoFamily
                                font.pixelSize: Typography.bodyLarge
                            }

                            Text {
                                width: 170
                                anchors.verticalCenter: parent.verticalCenter
                                text: eventRow.source
                                color: Colors.textPrimary
                                font.family: Typography.monoFamily
                                font.pixelSize: Typography.bodyLarge
                            }

                            Text {
                                width: parent.width - 390
                                anchors.verticalCenter: parent.verticalCenter
                                text: eventRow.description
                                color: Colors.textPrimary
                                font.family: Typography.monoFamily
                                font.pixelSize: Typography.bodyLarge
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
