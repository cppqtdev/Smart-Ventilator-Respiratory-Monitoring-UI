import QtQuick 2.15
import "../cards"
import "../../styles"

Item {
    id: root
    property var alarmData
    property var clockData
    property bool showAlarm: false
    property string mode: "ASV"
    property string patientCategory: "Adult"

    StatusPanel {
        anchors.left: parent.left
        anchors.leftMargin: Spacing.screenMargin
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(420, parent.width * 0.24)
        height: parent.height * 0.76
        mode: root.mode
        patientCategory: root.patientCategory
    }

    AlarmBanner {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.52
        height: parent.height * 0.76
        visible: root.showAlarm
        headline: root.alarmData ? root.alarmData.headline : ""
        detail: root.alarmData ? root.alarmData.detail : ""
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: Spacing.screenMargin
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(390, parent.width * 0.22)
        height: parent.height * 0.76
        radius: Radius.medium
        color: Colors.surface

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 28
            anchors.verticalCenter: parent.verticalCenter
            text: root.clockData ? root.clockData.dateTimeText : "--\n--:-- --"
            color: Colors.textPrimary
            font.pixelSize: Math.max(18, parent.height * 0.22)
            font.bold: true
            lineHeight: 1.1
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 26
            anchors.verticalCenter: parent.verticalCenter
            text: "AC  |  Battery 92%"
            color: Colors.textPrimary
            font.pixelSize: Math.max(16, parent.height * 0.18)
        }
    }
}
