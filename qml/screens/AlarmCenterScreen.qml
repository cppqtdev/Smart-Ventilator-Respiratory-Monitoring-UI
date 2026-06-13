import QtQuick 2.15
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
            PrimaryButton { width: 170; text: "Critical"; buttonColor: Colors.critical }
            PrimaryButton { width: 170; text: "Warning"; buttonColor: Colors.warning }
            PrimaryButton { width: 170; text: "Info"; buttonColor: Colors.accentBlue }
            PrimaryButton {
                width: 260
                text: "Acknowledge"
                buttonColor: Colors.success
                onClicked: root.alarmData.acknowledgeActiveAlarm()
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
                            font.pixelSize: 22
                            font.bold: true
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
                        color: alarmRowDelegate.priority === "Critical" ? "#7B2A35" : alarmRowDelegate.priority === "Warning" ? "#65552A" : Colors.surfaceRaised
                        Row {
                            anchors.fill: parent
                            anchors.margins: 18
                            Text { width: parent.width / 5; text: alarmRowDelegate.time; color: Colors.textPrimary; font.pixelSize: 22 }
                            Text { width: parent.width / 5; text: alarmRowDelegate.priority; color: Colors.textPrimary; font.pixelSize: 22; font.bold: true }
                            Text { width: parent.width / 5; text: alarmRowDelegate.source; color: Colors.textPrimary; font.pixelSize: 22 }
                            Text { width: parent.width / 5; text: alarmRowDelegate.description; color: Colors.textPrimary; font.pixelSize: 22; elide: Text.ElideRight }
                            Text { width: parent.width / 5; text: alarmRowDelegate.status; color: Colors.textPrimary; font.pixelSize: 22 }
                        }
                    }
                }
            }
        }
    }
}
