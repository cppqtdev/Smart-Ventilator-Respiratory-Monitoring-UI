pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: AlarmCenterScreen.qml
// Description: Alarm history table with severity filtering and acknowledge actions
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick.Controls.Basic
import QtQuick
import "../styles"
import "../components/cards"
import "../components/buttons"

Item {
    id: root
    property var alarmData

    Column {
        anchors.fill: parent
        spacing: 14

        // Action bar: filter buttons, acknowledge, silence
        Row {
            width: parent.width
            height: 60
            spacing: 12

            PrimaryButton {
                width: 130
                height: parent.height
                text: "All"
                buttonColor: root.alarmData.filterPriority === ""
                    ? Colors.accentBlue : Colors.surfaceRaised
                onClicked: root.alarmData.setFilterPriority("")
            }

            PrimaryButton {
                width: 130
                height: parent.height
                text: "Critical"
                buttonColor: root.alarmData.filterPriority === "Critical"
                    ? Colors.critical : Colors.surfaceRaised
                onClicked: root.alarmData.setFilterPriority(
                    root.alarmData.filterPriority === "Critical"
                        ? "" : "Critical")
            }

            PrimaryButton {
                width: 130
                height: parent.height
                text: "Warning"
                buttonColor: root.alarmData.filterPriority === "Warning"
                    ? Colors.warning : Colors.surfaceRaised
                onClicked: root.alarmData.setFilterPriority(
                    root.alarmData.filterPriority === "Warning"
                        ? "" : "Warning")
            }

            PrimaryButton {
                width: 110
                height: parent.height
                text: "Info"
                buttonColor: root.alarmData.filterPriority === "Info"
                    ? Colors.accentBlueDark : Colors.surfaceRaised
                onClicked: root.alarmData.setFilterPriority(
                    root.alarmData.filterPriority === "Info"
                        ? "" : "Info")
            }

            Item { width: 12; height: 1 }

            PrimaryButton {
                width: 200
                height: parent.height
                text: "Acknowledge"
                buttonColor: root.alarmData.active
                    ? Colors.success : Colors.disabled
                onClicked: root.alarmData.acknowledgeActiveAlarm()
            }

            PrimaryButton {
                width: 220
                height: parent.height
                text: root.alarmData.silenced
                    ? "Silenced (" + root.alarmData.silenceRemaining + "s)"
                    : "Silence 120s"
                buttonColor: root.alarmData.silenced
                    ? Colors.warning : Colors.buttonMuted
                onClicked: {
                    if (root.alarmData.silenced)
                        root.alarmData.cancelSilence()
                    else
                        root.alarmData.silenceAlarms(120)
                }
            }

            Item { width: 1; height: 1 }

            // Alarm count badge
            Rectangle {
                width: 60
                height: parent.height
                radius: Radius.small
                color: Colors.surfaceRaised
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: root.alarmData.alarmCount
                    color: Colors.textPrimary
                    font.pixelSize: Typography.subtitle
                    font.weight: Font.DemiBold
                }
            }
        }

        // Active alarm flash banner
        Rectangle {
            width: parent.width
            height: root.alarmData.active ? 52 : 0
            radius: Radius.small
            visible: root.alarmData.active
            color: Colors.critical

            // IEC 60601-1-8: critical alarms require flashing visual.
            SequentialAnimation on opacity {
                running: root.alarmData.active
                    && !root.alarmData.silenced
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.4; duration: 400
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: 1.0; duration: 400
                    easing.type: Easing.InOutQuad
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    text: root.alarmData.silenced ? "\u{1F507}" : "\u{1F514}"
                    font.pixelSize: Typography.body
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.alarmData.priority + ": "
                        + root.alarmData.headline
                        + " -- " + root.alarmData.detail
                    color: Colors.textPrimary
                    font.pixelSize: Typography.body
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Behavior on height {
                NumberAnimation { duration: 200 }
            }
        }

        // Alarm history table
        Panel {
            width: parent.width
            height: parent.height
                - (root.alarmData.active ? 140 : 88)
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 8

                // Table header
                Row {
                    width: parent.width
                    height: 40

                    Repeater {
                        model: [
                            "Time", "Priority", "Source",
                            "Description", "Status"
                        ]
                        Text {
                            required property string modelData
                            width: parent.width / 5
                            text: modelData
                            color: Colors.textSecondary
                            font.pixelSize: Typography.label
                            font.weight: Font.DemiBold
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.line
                }

                // Scrollable alarm rows
                ListView {
                    width: parent.width
                    height: parent.height - 52
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: 6
                    model: root.alarmData
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    Text {
                        width: parent.width
                        visible: root.alarmData.alarmCount === 0
                        topPadding: 60
                        text: "No alarms recorded"
                        color: Colors.textMuted
                        font.pixelSize: Typography.subtitle
                        horizontalAlignment: Text.AlignHCenter
                    }

                    delegate: Rectangle {
                        id: alarmRowDelegate
                        required property string time
                        required property string priority
                        required property string source
                        required property string description
                        required property string status

                        width: ListView.view.width
                        height: 68
                        radius: Radius.small
                        color: alarmRowDelegate.priority === "Critical"
                            ? Colors.criticalBackground
                            : alarmRowDelegate.priority === "Warning"
                                ? Colors.warningBackground
                                : Colors.surfaceRaised

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            Text {
                                width: parent.width / 5
                                anchors.verticalCenter: parent.verticalCenter
                                text: alarmRowDelegate.time
                                color: Colors.textPrimary
                                font.family: Typography.monoFamily
                                font.pixelSize: Typography.body
                            }
                            Text {
                                width: parent.width / 5
                                anchors.verticalCenter: parent.verticalCenter
                                text: alarmRowDelegate.priority
                                color: Colors.textPrimary
                                font.pixelSize: Typography.body
                                font.weight: Font.DemiBold
                            }
                            Text {
                                width: parent.width / 5
                                anchors.verticalCenter: parent.verticalCenter
                                text: alarmRowDelegate.source
                                color: Colors.textPrimary
                                font.pixelSize: Typography.body
                            }
                            Text {
                                width: parent.width / 5
                                anchors.verticalCenter: parent.verticalCenter
                                text: alarmRowDelegate.description
                                color: Colors.textPrimary
                                font.pixelSize: Typography.body
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width / 5
                                anchors.verticalCenter: parent.verticalCenter
                                text: alarmRowDelegate.status
                                color: alarmRowDelegate.status === "Active"
                                    ? Colors.critical
                                    : alarmRowDelegate.status === "Acknowledged"
                                        ? Colors.warning
                                        : Colors.successBright
                                font.pixelSize: Typography.body
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }
        }
    }
}
