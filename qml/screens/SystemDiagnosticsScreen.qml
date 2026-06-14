pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../styles"
import "../components/cards"
import "../components/buttons"
import "../components/charts"

Page {
    id: root
    property var clockData
    property var appSettingsData
    property int currentTab: 0

    readonly property var tabs: ["Info", "Tests & Calib", "Sensors", "Settings"]

    padding: 24

    function loadScreen(screen) {
        mainLoader.sourceComponent = screen
    }

    background: Rectangle {
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
        border.width: 1
    }

    header: Control {
        padding: 24

        contentItem: RowLayout {
            spacing: 20

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Info"
                checked: true
                onClicked: loadScreen(infoPage)
            }

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Tests & Calib"
                onClicked: loadScreen(testsPage)
            }

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Sensors"
                onClicked: loadScreen(sensorsPage)
            }

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Settings"
                onClicked: loadScreen(settingsPage)
            }
        }
    }

    contentItem: Loader {
        id: mainLoader
        sourceComponent: infoPage
    }

    Component {
        id: infoPage
        Row {
            spacing: 22

            ColumnLayout {
                width: parent.width * 0.28
                spacing: 14

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Info 1"
                    checked: true
                    onClicked: {}
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Info 2"
                    onClicked: {}
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Info 3"
                    onClicked: {}
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
                        height: 48
                        spacing: 18

                        PrimaryButton { width: 230; height: parent.height; text: testRow.modelData[0]; buttonColor: "#9AA2AE" }

                        Rectangle {
                            width: 48
                            height: 48
                            radius: Radius.small
                            color: "transparent"
                            border.color: Colors.line
                            border.width: 2

                            Text { anchors.centerIn: parent; text: testRow.modelData[1] === "Passed" ? "✓" : "•"; color: testRow.modelData[1] === "Passed" ? "#18C889" : Colors.warning; font.pixelSize: 28; font.bold: true }
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
            spacing: 24

            PrimaryButton { width: 230; height: 48; text: "On/Off"; buttonColor: "#9AA2AE" }

            Rectangle {
                width: 48
                height: 48
                radius: Radius.small
                color: "transparent"
                border.color: Colors.line
                border.width: 2

                Text { anchors.centerIn: parent; text: "✓"; color: "#18C889"; font.pixelSize: 28; font.bold: true }
            }

        }
    }

    Component {
        id: settingsPage
        Row {
            spacing: 20

            ColumnLayout {
                width: parent.width * 0.28
                spacing: 14

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Loudness"
                    checked: true
                    onClicked: {}
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Day & Night"
                    onClicked: {}
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Day & Time"
                    onClicked: {}
                }
            }

            Rectangle {
                width: parent.width * 0.58
                height: parent.height * 0.84
                radius: Radius.small
                color: Colors.background
                clip: true

                Column {
                    anchors.centerIn: parent
                    width: parent.width * 0.68
                    spacing: 20

                    PressureGroupBox {
                        anchors.horizontalCenter: parent.horizontalCenter
                        labelText: "Loudness";
                        value: 60;
                        unit: "%"
                    }

                    RowLayout {
                        width: parent.width
                        spacing: 10

                        PrefsTabButton {
                            Layout.fillWidth: true
                            checked: true
                            text: "Day"
                            onClicked: {}
                        }

                        PrefsTabButton {
                            Layout.fillWidth: true
                            text: "Night"
                            onClicked: {}
                        }

                        PrefsTabButton {
                            Layout.fillWidth: true
                            text: "Automatic"
                            onClicked: {}
                        }
                    }

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
