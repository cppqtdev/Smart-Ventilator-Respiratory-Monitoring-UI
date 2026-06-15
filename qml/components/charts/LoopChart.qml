// -----------------------------------------------------------------------
// File: LoopChart.qml
// Description: XY plot for pressure-volume and flow-volume respiratory loops
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import "../../styles"
import "../cards"

Panel {
    id: root

    property string title: "P-V Loop"
    property string xLabel: "Volume (mL)"
    property string yLabel: "Pressure (cmH2O)"
    property var xSamples: []
    property var ySamples: []
    property real xMinimum: 0
    property real xMaximum: 800
    property real yMinimum: 0
    property real yMaximum: 60
    property color traceColor: Colors.cyan

    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 16
        text: root.title
        color: root.traceColor
        font.pixelSize: Typography.subtitle
        font.weight: Font.DemiBold
    }

    Text {
        anchors.horizontalCenter: chart.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        text: root.xLabel
        color: Colors.textMuted
        font.pixelSize: Typography.caption
    }

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: chart.verticalCenter
        anchors.leftMargin: 6
        rotation: -90
        text: root.yLabel
        color: Colors.textMuted
        font.pixelSize: Typography.caption
    }

    Canvas {
        id: chart
        anchors.fill: parent
        anchors.leftMargin: 58
        anchors.rightMargin: 24
        anchors.topMargin: 52
        anchors.bottomMargin: 42
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            ctx.reset()
            ctx.clearRect(0, 0, w, h)

            ctx.lineWidth = 1
            for (var i = 0; i <= 5; ++i) {
                ctx.strokeStyle = i === 0 || i === 5
                    ? Qt.rgba(1, 1, 1, 0.16)
                    : Qt.rgba(1, 1, 1, 0.07)
                ctx.beginPath()
                ctx.moveTo(0, i * h / 5)
                ctx.lineTo(w, i * h / 5)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(i * w / 5, 0)
                ctx.lineTo(i * w / 5, h)
                ctx.stroke()
            }

            var xs = root.xSamples
            var ys = root.ySamples
            var count = Math.min(xs ? xs.length : 0, ys ? ys.length : 0)
            if (count < 2)
                return

            var xr = Math.max(0.1, root.xMaximum - root.xMinimum)
            var yr = Math.max(0.1, root.yMaximum - root.yMinimum)
            function point(index) {
                var nx = (xs[index] - root.xMinimum) / xr
                var ny = (ys[index] - root.yMinimum) / yr
                return {
                    x: Math.max(0, Math.min(1, nx)) * w,
                    y: h - Math.max(0, Math.min(1, ny)) * h
                }
            }

            ctx.strokeStyle = root.traceColor
            ctx.lineWidth = 2.5
            ctx.lineJoin = "round"
            ctx.lineCap = "round"
            ctx.beginPath()
            var first = point(0)
            ctx.moveTo(first.x, first.y)
            for (var j = 1; j < count; ++j) {
                var p = point(j)
                ctx.lineTo(p.x, p.y)
            }
            ctx.stroke()

            var latest = point(count - 1)
            ctx.fillStyle = root.traceColor
            ctx.beginPath()
            ctx.arc(latest.x, latest.y, 4, 0, Math.PI * 2)
            ctx.fill()
        }

        Connections {
            target: root
            function onXSamplesChanged() { chart.requestPaint() }
            function onYSamplesChanged() { chart.requestPaint() }
            function onTraceColorChanged() { chart.requestPaint() }
        }
    }

    Text {
        anchors.left: chart.left
        anchors.bottom: chart.top
        anchors.bottomMargin: 3
        text: root.yMaximum
        color: Colors.textUnit
        font.pixelSize: 10
    }

    Text {
        anchors.left: chart.left
        anchors.top: chart.bottom
        anchors.topMargin: 3
        text: root.xMinimum
        color: Colors.textUnit
        font.pixelSize: 10
    }

    Text {
        anchors.right: chart.right
        anchors.top: chart.bottom
        anchors.topMargin: 3
        text: root.xMaximum
        color: Colors.textUnit
        font.pixelSize: 10
    }
}
