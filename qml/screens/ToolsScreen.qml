pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"
import "../components/charts"
import "../components/buttons"

Item {
    id: root
    property var ventilatorData
    property var alarmData
    property int currentTab: 0
    readonly property var tabs: ["Page 1", "Page 2", "Alarm Log"]

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
                        Text { anchors.centerIn: parent; text: tabDelegate.modelData; color: Colors.textPrimary; font.family: "Courier New"; font.pixelSize: 23; font.bold: true }
                        MouseArea { anchors.fill: parent; onClicked: root.currentTab = tabDelegate.index }
                    }
                }
            }

            Loader {
                width: parent.width
                height: parent.height - tabRow.height
                sourceComponent: root.currentTab === 0 ? pageOne : root.currentTab === 1 ? pageTwo : alarmLog
            }
        }
    }

    Component {
        id: pageOne
        Grid {
            anchors.margins: 30
            columns: 3
            spacing: 34
            property real cellWidth: (width - spacing * 2) / 3
            property real cellHeight: Math.max(190, (height - spacing) / 2)
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Apnea Time"; value: 20; maximum: 60; unit: "s" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "PetCO2"; value: 60; maximum: 100; unit: "mmHg" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "SpO2"; value: 90; maximum: 100; unit: "%" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Low Pressure"; value: 5; maximum: 40; unit: "cmH2O" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "ExpMinVol"; value: 30; maximum: 60; unit: "%" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "VT Low"; value: 270; maximum: 900; unit: "mL" }
        }
    }

    Component {
        id: pageTwo
        Grid {
            anchors.margins: 30
            columns: 4
            spacing: 28
            property real cellWidth: (width - spacing * 3) / 4
            property real cellHeight: Math.max(170, (height - spacing) / 2)
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Oxygen"; value: root.ventilatorData.fio2; unit: "%" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "ExpMinVol"; value: 95; maximum: 200; unit: "%" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Ftotal"; value: 40; maximum: 80; unit: "b/min" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "VT"; value: 800; maximum: 1000; unit: "mL" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Low PEEP"; value: 5; maximum: 30; unit: "cmH2O" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Leak"; value: 4; maximum: 20; unit: "%" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "Reserve"; value: 0; maximum: 100; unit: "%" }
            CircularKnob { width: parent.cellWidth; height: parent.cellHeight; label: "VT High"; value: 270; maximum: 900; unit: "mL" }
        }
    }

    Component {
        id: alarmLog
        EventsScreen { alarmData: root.alarmData }
    }
}
