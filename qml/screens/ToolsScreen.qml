pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: ToolsScreen.qml
// Description: Utility gauges and alarm log across three pages
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../styles"
import "../components/cards"
import "../components/charts"
import "../components/buttons"

Page {
    id: root
    property var ventilatorData
    property var alarmData
    property var eventData
    property int currentTab: 0

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
                text: "Page 1"
                checked: true
                onClicked: loadScreen(pageOne)
            }

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Page 2"
                onClicked: loadScreen(pageTwo)
            }

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Page 3"
                onClicked: loadScreen(alarmLog)
            }
        }
    }

    contentItem: Loader {
        id: mainLoader
        sourceComponent: pageOne
    }

    Component {
        id: pageOne
        Grid {
            columns: 3
            spacing: 34
            property real cellWidth: (width - spacing * 2) / 3
            property real cellHeight: Math.max(190, (height - spacing) / 2)
            PressureGroupBox {  labelText: "Apnea Time"; value: 20; maximumValue: 60; unit: "s" }
            PressureGroupBox {  labelText: "PetCO2"; value: 60; maximumValue: 100; unit: "mmHg" }
            PressureGroupBox {  labelText: "SpO2"; value: 90; maximumValue: 100; unit: "%" }
            PressureGroupBox {  labelText: "Low Pressure"; value: 5; maximumValue: 40; unit: "cmH2O" }
            PressureGroupBox {  labelText: "ExpMinVol"; value: 30; maximumValue: 60; unit: "%" }
            PressureGroupBox {  labelText: "VT Low"; value: 270; maximumValue: 900; unit: "mL" }
        }
    }

    Component {
        id: pageTwo
        Grid {
            columns: 4
            spacing: 28
            property real cellWidth: (width - spacing * 3) / 4
            property real cellHeight: Math.max(170, (height - spacing) / 2)
            PressureGroupBox {  labelText: "Oxygen"; value: root.ventilatorData.fio2; unit: "%" }
            PressureGroupBox {  labelText: "ExpMinVol"; value: 95; maximumValue: 200; unit: "%" }
            PressureGroupBox {  labelText: "Ftotal"; value: 40; maximumValue: 80; unit: "b/min" }
            PressureGroupBox {  labelText: "VT"; value: 800; maximumValue: 1000; unit: "mL" }
            PressureGroupBox {  labelText: "Low PEEP"; value: 5; maximumValue: 30; unit: "cmH2O" }
            PressureGroupBox {  labelText: "Leak"; value: 4; maximumValue: 20; unit: "%" }
            PressureGroupBox {  labelText: "Reserve"; value: 0; maximumValue: 100; unit: "%" }
            PressureGroupBox {  labelText: "VT High"; value: 270; maximumValue: 900; unit: "mL" }
        }
    }

    Component {
        id: alarmLog

        EventsScreen {
            alarmData: root.alarmData
            eventData: root.eventData
            padding: 0
            background: null
        }
    }
}
