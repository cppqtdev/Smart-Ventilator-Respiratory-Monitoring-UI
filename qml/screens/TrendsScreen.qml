pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: TrendsScreen.qml
// Description: Historical trend graphs for ventilator parameters
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../styles"
import "../components/cards"
import "../components/buttons"

Page {
    id: root
    property var ventilatorData
    property var databaseData
    property int timeWindowMinutes: 60
    property var trendData: []

    padding: 0

    function refreshTrends() {
        if (root.databaseData)
            root.trendData = root.databaseData.getParameterHistory(
                root.timeWindowMinutes)
    }

    // Auto-refresh every 5 seconds
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refreshTrends()
    }

    Component.onCompleted: root.refreshTrends()

    readonly property var trendConfigs: [
        { key: "ppeak",  label: "Ppeak",  unit: "cmH2O", color: Colors.success,    min: 0,  max: 60 },
        { key: "spo2",   label: "SpO2",   unit: "%",      color: Colors.cyan,       min: 80, max: 100 },
        { key: "etco2",  label: "EtCO2",  unit: "mmHg",   color: Colors.accentBlue, min: 15, max: 60 },
        { key: "fio2",   label: "FiO2",   unit: "%",      color: Colors.magenta,    min: 20, max: 100 },
        { key: "peep",   label: "PEEP",   unit: "cmH2O",  color: Colors.warning,    min: 0,  max: 30 },
        { key: "compliance", label: "Cstat", unit: "mL/cmH2O", color: Colors.successBright, min: 0, max: 100 }
    ]

    background: Rectangle {
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
        border.width: 1
    }

    header: Control {
        padding: 20

        contentItem: RowLayout {
            spacing: 14

            Text {
                text: "Trends"
                color: Colors.textPrimary
                font.pixelSize: Typography.title
                font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Repeater {
                model: [
                    { label: "1h",  val: 60 },
                    { label: "6h",  val: 360 },
                    { label: "12h", val: 720 },
                    { label: "24h", val: 1440 }
                ]
                PrefsTabButton {
                    id: twBtn
                    required property var modelData
                    width: 70
                    height: 40
                    text: twBtn.modelData.label
                    checked: root.timeWindowMinutes === twBtn.modelData.val
                    onClicked: {
                        root.timeWindowMinutes = twBtn.modelData.val
                        root.refreshTrends()
                    }
                }
            }

            PrimaryButton {
                width: 100
                height: 40
                text: "Refresh"
                buttonColor: Colors.accentBlue
                onClicked: root.refreshTrends()
            }
        }
    }

    contentItem: Flickable {
        contentWidth: width
        contentHeight: trendGrid.height + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        GridLayout {
            id: trendGrid
            x: 20
            width: parent.width - 40
            columns: 2
            columnSpacing: 16
            rowSpacing: 16

            Repeater {
                model: root.trendConfigs

                Panel {
                    id: trendPanel
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    clip: true

                    // Title + current value
                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 14
                        z: 2

                        Text {
                            text: trendPanel.modelData.label
                            color: trendPanel.modelData.color
                            font.pixelSize: Typography.label
                            font.weight: Font.DemiBold
                        }

                        Item { width: 8; height: 1 }

                        Text {
                            text: "(" + trendPanel.modelData.unit + ")"
                            color: Colors.textMuted
                            font.pixelSize: Typography.caption
                            anchors.baseline: parent.children[0].baseline
                        }

                        Item {
                            width: parent.width
                                - parent.children[0].width
                                - parent.children[1].width
                                - parent.children[2].width
                                - parent.children[4].width - 24
                            height: 1
                        }

                        Text {
                            text: {
                                if (root.trendData.length === 0)
                                    return "--"
                                var last = root.trendData[
                                    root.trendData.length - 1]
                                var v = last[trendPanel.modelData.key]
                                return v !== undefined
                                    ? Math.round(v * 10) / 10 : "--"
                            }
                            color: trendPanel.modelData.color
                            font.pixelSize: Typography.subtitle
                            font.family: Typography.monoFamily
                            font.weight: Font.DemiBold
                        }
                    }

                    // Scale labels
                    Text {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 38
                        anchors.rightMargin: 14
                        text: trendPanel.modelData.max
                        color: Colors.textUnit
                        font.pixelSize: 10
                        font.family: Typography.monoFamily
                        z: 2
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 14
                        text: trendPanel.modelData.min
                        color: Colors.textUnit
                        font.pixelSize: 10
                        font.family: Typography.monoFamily
                        z: 2
                    }

                    // Trend chart canvas
                    Canvas {
                        id: trendCanvas
                        anchors.fill: parent
                        anchors.topMargin: 36
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 14
                        anchors.rightMargin: 40

                        onPaint: {
                            var ctx = getContext("2d")
                            var w = width
                            var h = height
                            ctx.reset()
                            ctx.clearRect(0, 0, w, h)

                            // Grid
                            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.06)
                            ctx.lineWidth = 0.5
                            for (var gi = 1; gi < 4; gi++) {
                                ctx.beginPath()
                                ctx.moveTo(0, gi * h / 4)
                                ctx.lineTo(w, gi * h / 4)
                                ctx.stroke()
                            }
                            for (var gj = 1; gj < 8; gj++) {
                                ctx.beginPath()
                                ctx.moveTo(gj * w / 8, 0)
                                ctx.lineTo(gj * w / 8, h)
                                ctx.stroke()
                            }

                            var data = root.trendData
                            var key = trendPanel.modelData.key
                            var vmin = trendPanel.modelData.min
                            var vmax = trendPanel.modelData.max
                            var range = Math.max(1, vmax - vmin)

                            if (!data || data.length < 2) {
                                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.1)
                                ctx.setLineDash([6, 6])
                                ctx.beginPath()
                                ctx.moveTo(0, h / 2)
                                ctx.lineTo(w, h / 2)
                                ctx.stroke()
                                return
                            }

                            // Area fill
                            var tc = trendPanel.modelData.color
                            ctx.fillStyle = Qt.rgba(tc.r, tc.g, tc.b, 0.08)
                            ctx.beginPath()
                            ctx.moveTo(0, h)
                            for (var a = 0; a < data.length; a++) {
                                var ax = a * w / (data.length - 1)
                                var av = data[a][key]
                                if (av === undefined) av = vmin
                                var an = (av - vmin) / range
                                var ay = h - Math.max(0, Math.min(1, an)) * h
                                ctx.lineTo(ax, ay)
                            }
                            ctx.lineTo(w, h)
                            ctx.closePath()
                            ctx.fill()

                            // Line
                            ctx.strokeStyle = trendPanel.modelData.color
                            ctx.lineWidth = 2
                            ctx.lineJoin = "round"
                            ctx.beginPath()
                            for (var b = 0; b < data.length; b++) {
                                var bx = b * w / (data.length - 1)
                                var bv = data[b][key]
                                if (bv === undefined) bv = vmin
                                var bn = (bv - vmin) / range
                                var by = h - Math.max(0, Math.min(1, bn)) * h
                                if (b === 0) ctx.moveTo(bx, by)
                                else ctx.lineTo(bx, by)
                            }
                            ctx.stroke()

                            // Last point dot
                            var lastVal = data[data.length - 1][key]
                            if (lastVal !== undefined) {
                                var ln = (lastVal - vmin) / range
                                var ly = h - Math.max(0, Math.min(1, ln)) * h
                                ctx.fillStyle = trendPanel.modelData.color
                                ctx.beginPath()
                                ctx.arc(w, ly, 4, 0, Math.PI * 2)
                                ctx.fill()
                            }
                        }

                        Connections {
                            target: root
                            function onTrendDataChanged() {
                                trendCanvas.requestPaint()
                            }
                        }
                    }

                    // Time labels
                    Text {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.margins: 8
                        text: "-" + (root.timeWindowMinutes >= 60
                            ? (root.timeWindowMinutes / 60) + "h"
                            : root.timeWindowMinutes + "m")
                        color: Colors.textUnit
                        font.pixelSize: 10
                        z: 2
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 44
                        anchors.bottomMargin: 8
                        text: "now"
                        color: Colors.textUnit
                        font.pixelSize: 10
                        z: 2
                    }
                }
            }

            // Data count info
            Text {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                text: root.trendData.length + " data points over "
                    + (root.timeWindowMinutes >= 60
                        ? (root.timeWindowMinutes / 60) + " hours"
                        : root.timeWindowMinutes + " minutes")
                color: Colors.textMuted
                font.pixelSize: Typography.caption
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
