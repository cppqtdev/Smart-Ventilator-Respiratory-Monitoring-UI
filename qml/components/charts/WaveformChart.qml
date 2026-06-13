import QtQuick 2.15
import "../../styles"
import "../cards"
Panel {
    id: root
    property string title: "Paw"
    property color traceColor: Colors.success
    property int rows: 1
    property var samples: []
    property real minimumValue: 0
    property real maximumValue: 40

    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 18
        text: root.title
        color: Colors.textPrimary
        font.pixelSize: 26
        font.bold: true
        z: 2
    }

    Canvas {
        id: chartCanvas
        anchors.fill: parent
        anchors.margins: 18
        anchors.topMargin: 56
        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            ctx.clearRect(0, 0, w, h)
            ctx.strokeStyle = Colors.line
            ctx.lineWidth = 1
            ctx.setLineDash([8, 8])
            for (var i = 1; i < 8; i++) {
                ctx.beginPath()
                ctx.moveTo(i * w / 8, 0)
                ctx.lineTo(i * w / 8, h)
                ctx.stroke()
            }
            for (var j = 1; j < 4; j++) {
                ctx.beginPath()
                ctx.moveTo(0, j * h / 4)
                ctx.lineTo(w, j * h / 4)
                ctx.stroke()
            }
            ctx.setLineDash([])
            ctx.strokeStyle = root.traceColor
            ctx.lineWidth = 4
            ctx.beginPath()

            var data = root.samples
            if (!data || data.length < 2) {
                for (var x = 0; x <= w; x++) {
                    var t = x / w * Math.PI * 8
                    var breath = Math.pow(Math.max(0, Math.sin(t)), 0.45)
                    var y = h * 0.72 - breath * h * 0.42 + Math.sin(t * 1.7) * 5
                    if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                }
            } else {
                var range = Math.max(1, root.maximumValue - root.minimumValue)
                for (var i = 0; i < data.length; i++) {
                    var px = i * w / Math.max(1, data.length - 1)
                    var normalized = (data[i] - root.minimumValue) / range
                    var py = h - Math.max(0, Math.min(1, normalized)) * h
                    if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
                }
            }
            ctx.stroke()
        }
    }

    onSamplesChanged: chartCanvas.requestPaint()
    onMinimumValueChanged: chartCanvas.requestPaint()
    onMaximumValueChanged: chartCanvas.requestPaint()
}
