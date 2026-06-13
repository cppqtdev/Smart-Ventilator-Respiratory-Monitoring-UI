pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"
import "../components/buttons"
import "../components/charts"

Item {
    id: root
    property var clockData
    property var appSettingsData
    property int currentTab: 0

    readonly property var tabs: ["Info", "Tests & Calib", "Sensors", "Settings"]

    Panel {
        anchors.fill: parent
        clip: true

        Column {
            anchors.fill: parent

            Row {
                id: tabRow
                width: parent.width
                height: 66
                Repeater {
                    model: root.tabs
                    Rectangle {
                        id: tabDelegate
                        required property int index
                        required property string modelData
                        width: tabRow.width / root.tabs.length
                        height: tabRow.height
                        color: root.currentTab === tabDelegate.index ? "#18C889" : "#079B66"
                        border.color: "#08714E"
                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 18
                            text: tabDelegate.modelData
                            color: Colors.textPrimary
                            font.family: "Courier New"
                            font.pixelSize: 22
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            minimumPixelSize: 16
                            fontSizeMode: Text.Fit
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.currentTab = tabDelegate.index }
                    }
                }
            }

            Loader {
                width: parent.width
                height: parent.height - tabRow.height
                sourceComponent: root.currentTab === 0 ? infoPage
                               : root.currentTab === 1 ? testsPage
                               : root.currentTab === 2 ? sensorsPage
                               : settingsPage
            }
        }
    }

    Component {
        id: infoPage
        Row {
            anchors.margins: 24
            spacing: 22

            Column {
                width: parent.width * 0.26
                spacing: 16
                Repeater {
                    model: ["Info 1", "Info 2", "Info 3"]
                    PrimaryButton {
                        id: infoButton
                        required property string modelData
                        width: parent.width
                        height: 66
                        text: infoButton.modelData
                        buttonColor: "#9AA2AE"
                    }
                }
            }

            Rectangle {
                width: parent.width * 0.68
                height: parent.height * 0.78
                radius: Radius.small
                color: "#59647C"
                clip: true
                Text {
                    anchors.fill: parent
                    anchors.margins: 24
                    text: "Options:\t\t---\n\nAdult/ped.\t\tNeonatal\nnCPAP\t\tTRC\nDuoPAP/APRV\t\tTrends/Loops\nNIV/NIV-ST\t\tP/V Tool Pro\nMasimo Rainbow\t\t---\nHi Flow O2\t\t---"
                    color: Colors.textPrimary
                    font.family: "Courier New"
                    font.pixelSize: 23
                    wrapMode: Text.WordWrap
                    lineHeight: 1.22
                }
            }
        }
    }

    Component {
        id: testsPage
        Flickable {
            contentWidth: width
            contentHeight: testColumn.height + 48
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: testColumn
                x: 24
                y: 24
                width: parent.width - 48
                spacing: 18

                Repeater {
                    model: [
                        ["Tightness", "Passed", "2026-06-12 18:51"],
                        ["Flow Sensor", "Passed", "2026-06-12 18:51"],
                        ["O2 Cell", "Passed", "2026-06-12 18:51"],
                        ["Circuit Test", "Ready", "Not run"]
                    ]
                    Row {
                        id: testRow
                        required property var modelData
                        width: parent.width
                        height: 66
                        spacing: 18
                        PrimaryButton { width: 230; height: parent.height; text: testRow.modelData[0]; buttonColor: "#9AA2AE" }
                        Rectangle {
                            width: 66
                            height: 66
                            radius: Radius.small
                            color: "transparent"
                            border.color: Colors.line
                            border.width: 2
                            Text { anchors.centerIn: parent; text: testRow.modelData[1] === "Passed" ? "✓" : "•"; color: testRow.modelData[1] === "Passed" ? "#18C889" : Colors.warning; font.pixelSize: 48; font.bold: true }
                        }
                        Text { width: parent.width - 330; anchors.verticalCenter: parent.verticalCenter; text: testRow.modelData[2]; color: Colors.textPrimary; font.family: "Courier New"; font.pixelSize: 22; wrapMode: Text.WordWrap }
                    }
                }
            }
        }
    }

    Component {
        id: sensorsPage
        Row {
            anchors.margins: 24
            spacing: 24
            PrimaryButton { width: 230; height: 66; text: "On/Off"; buttonColor: "#9AA2AE" }
            Rectangle {
                width: 66
                height: 66
                radius: Radius.small
                color: "transparent"
                border.color: Colors.line
                border.width: 2
                Text { anchors.centerIn: parent; text: "✓"; color: "#18C889"; font.pixelSize: 48; font.bold: true }
            }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "O2 Cell"; color: Colors.textPrimary; font.family: "Courier New"; font.pixelSize: 24 }
        }
    }

    Component {
        id: settingsPage
        Row {
            anchors.margins: 24
            spacing: 20

            Column {
                width: parent.width * 0.28
                spacing: 14
                Repeater {
                    model: ["Loudness", "Day & Night", "Day & Time"]
                    PrimaryButton {
                        id: settingsButton
                        required property string modelData
                        width: parent.width
                        height: 64
                        text: settingsButton.modelData
                        buttonColor: "#9AA2AE"
                    }
                }
            }

            Rectangle {
                width: parent.width * 0.58
                height: parent.height * 0.84
                radius: Radius.small
                color: "#59647C"
                clip: true

                Column {
                    anchors.centerIn: parent
                    width: parent.width * 0.68
                    spacing: 20
                    CircularKnob { width: parent.width; height: 180; label: "Loudness"; value: 60; unit: "%" }
                    Row {
                        width: parent.width
                        spacing: 14
                        PrimaryButton { width: (parent.width - parent.spacing) / 2; text: "Day"; buttonColor: Colors.accentBlue }
                        PrimaryButton { width: (parent.width - parent.spacing) / 2; text: "Night"; buttonColor: "#236AB2" }
                    }
                    PrimaryButton { width: parent.width * 0.68; anchors.horizontalCenter: parent.horizontalCenter; text: "Automatic"; buttonColor: "#236AB2" }
                    Text {
                        width: parent.width
                        text: "Date: " + (root.clockData ? root.clockData.dateText : "--") + "\nTime: " + (root.clockData ? root.clockData.timeText : "--")
                        color: Colors.textPrimary
                        font.family: "Courier New"
                        font.pixelSize: 22
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
