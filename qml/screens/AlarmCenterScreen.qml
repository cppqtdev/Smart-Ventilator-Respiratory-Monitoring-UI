pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: AlarmCenterScreen.qml
// Description: Alarm history table with severity filtering and acknowledge actions
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import "../styles"
import "../components/cards"
import "../components/buttons"

Item {
    id: root
    property var alarmData

    Column {
        anchors.fill: parent
        spacing: 18
        Row {
            width: parent.width
            height: 70
            spacing: 18
            PrimaryButton { width: 170; text: "Critical"; buttonColor: root.alarmData.filterPriority === "Critical" ? Colors.critical : Colors.surfaceRaised; onClicked: root.alarmData.setFilterPriority(root.alarmData.filterPriority === "Critical" ? "" : "Critical") }
            PrimaryButton { width: 170; text: "Warning"; buttonColor: root.alarmData.filterPriority === "Warning" ? Colors.warning : Colors.surfaceRaised; onClicked: root.alarmData.setFilterPriority(root.alarmData.filterPriority === "Warning" ? "" : "Warning") }
            PrimaryButton { width: 170; text: "Info"; buttonColor: root.alarmData.filterPriority === "Info" ? Colors.accentBlue : Colors.surfaceRaised; onClicked: root.alarmData.setFilterPriority(root.alarmData.filterPriority === "Info" ? "" : "Info") }
            PrimaryButton {
                width: 260
                text: "Acknowledge"
                buttonColor: Colors.success
                onClicked: root.alarmData.acknowledgeActiveAlarm()
            }

            PrimaryButton {
                width: 260
                text: root.alarmData.silenced
                    ? "Silenced (" + root.alarmData.silenceRemaining + "s)"
                    : "Silence 120s"
                buttonColor: root.alarmData.silenced
                    ? Colors.warning
                    : Colors.buttonMuted
                onClicked: {
                    if (root.alarmData.silenced)
                        root.alarmData.cancelSilence()
                    else
                        root.alarmData.silenceAlarms(120)
                }
            }
        }
        Panel {
            width: parent.width
            height: parent.height - 88
            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12
                Row {
                    width: parent.width
                    height: 46
                    Repeater {
                        model: ["Time", "Priority", "Source", "Description", "Status"]
                        Text {
                            required property string modelData
                            width: parent.width / 5
                            text: modelData
                            color: Colors.textSecondary
                            font.pixelSize: Typography.bodyLarge
                            font.weight: Font.DemiBold
                        }
                    }
                }
                Repeater {
                    model: root.alarmData
                    Rectangle {
                        id: alarmRowDelegate
                        required property string time
                        required property string priority
                        required property string source
                        required property string description
                        required property string status

                        width: parent.width
                        height: 82
                        radius: Radius.small
                        color: alarmRowDelegate.priority === "Critical"
                                   ? Colors.criticalBackground
                                   : alarmRowDelegate.priority === "Warning"
                                     ? Colors.warningBackground
                                     : Colors.surfaceRaised
                        Row {
                            anchors.fill: parent
                            anchors.margins: 18
                            Text {
                                width: parent.width / 5
                                text: alarmRowDelegate.time
                                color: Colors.textPrimary
                                font.pixelSize: Typography.bodyLarge
                            }
                            Text {
                                width: parent.width / 5
                                text: alarmRowDelegate.priority
                                color: Colors.textPrimary
                                font.pixelSize: Typography.bodyLarge
                                font.weight: Font.DemiBold
                            }
                            Text {
                                width: parent.width / 5
                                text: alarmRowDelegate.source
                                color: Colors.textPrimary
                                font.pixelSize: Typography.bodyLarge
                            }
                            Text {
                                width: parent.width / 5
                                text: alarmRowDelegate.description
                                color: Colors.textPrimary
                                font.pixelSize: Typography.bodyLarge
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width / 5
                                text: alarmRowDelegate.status
                                color: Colors.textPrimary
                                font.pixelSize: Typography.bodyLarge
                            }
                        }
                    }
                }
            }
        }
    }
}
