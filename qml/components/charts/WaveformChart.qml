// -----------------------------------------------------------------------
// File: WaveformChart.qml
// Description: Canvas-based real-time waveform renderer with sweep cursor
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import "../../styles"
import "../cards"

Panel {
    id: root
    property string title: "Paw"
    property color traceColor: Colors.success
    property var samples: []
    property real minimumValue: 0
    property real maximumValue: 40
    property string unit: ""
    property bool frozen: false
    property real cursorA: -1
    property real cursorB: -1
    property real displaySeconds: 8.1
    property int maxFrameRate: 20
    property double _lastPaintRequestMs: 0

    readonly property int maxSamples: 180

    function schedulePaint() {
        var now = Date.now()
        if (root.frozen)
            return
        if (now - root._lastPaintRequestMs < 1000 / Math.max(1, root.maxFrameRate))
            return
        root._lastPaintRequestMs = now
        chartCanvas.requestPaint()
    }

    function valueAtCursor(cursorX) {
        if (!root.samples || root.samples.length === 0 || cursorX < 0)
            return 0
        var index = Math.round(cursorX / Math.max(1, chartCanvas.width)
                               * (root.samples.length - 1))
        index = Math.max(0, Math.min(root.samples.length - 1, index))
        return Number(root.samples[index])
    }

    // Title label (colored to match trace)
    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.topMargin: 10
        text: root.title
        color: root.traceColor
        font.pixelSize: Typography.label
        font.weight: Font.DemiBold
        z: 2
    }

    // Y-axis max label
    Text {
        anchors.right: chartCanvas.right
        anchors.top: chartCanvas.top
        anchors.topMargin: -2
        text: root.maximumValue
        color: Colors.textUnit
        font.pixelSize: 11
        font.family: Typography.monoFamily
        z: 2
    }

    // Y-axis min label
    Text {
        anchors.right: chartCanvas.right
        anchors.bottom: chartCanvas.bottom
        anchors.bottomMargin: -2
        text: root.minimumValue
        color: Colors.textUnit
        font.pixelSize: 11
        font.family: Typography.monoFamily
        z: 2
    }

    // Current numeric readout
    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 16
        anchors.topMargin: 8
        text: {
            var data = root.samples
            if (!data || data.length < 1) return "-- "
            var v = data[data.length - 1]
            return (Math.round(v * 10) / 10).toFixed(1)
        }
        color: root.traceColor
        font.pixelSize: Typography.subtitle
        font.family: Typography.monoFamily
        font.weight: Font.DemiBold
        z: 2
    }

    Canvas {
        id: chartCanvas
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 40
        anchors.topMargin: 34
        anchors.bottomMargin: 10

        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            ctx.reset()
            ctx.clearRect(0, 0, w, h)

            var range = Math.max(0.1,
                root.maximumValue - root.minimumValue)

            // ---- Major grid (solid, visible) ----
            ctx.lineWidth = 1
            ctx.setLineDash([])

            // Major horizontal grid: 5 divisions
            var hDivs = 5
            for (var hj = 0; hj <= hDivs; hj++) {
                var gy = Math.round(hj * h / hDivs) + 0.5
                ctx.strokeStyle = hj === 0 || hj === hDivs
                    ? Qt.rgba(1, 1, 1, 0.12)
                    : Qt.rgba(1, 1, 1, 0.06)
                ctx.beginPath()
                ctx.moveTo(0, gy)
                ctx.lineTo(w, gy)
                ctx.stroke()
            }

            // Major vertical grid: 10 divisions
            var vDivs = 10
            for (var vi = 0; vi <= vDivs; vi++) {
                var gx = Math.round(vi * w / vDivs) + 0.5
                ctx.strokeStyle = vi === 0 || vi === vDivs
                    ? Qt.rgba(1, 1, 1, 0.12)
                    : Qt.rgba(1, 1, 1, 0.06)
                ctx.beginPath()
                ctx.moveTo(gx, 0)
                ctx.lineTo(gx, h)
                ctx.stroke()
            }

            // ---- Minor grid (fine dots) ----
            ctx.lineWidth = 0.5
            ctx.setLineDash([1, 5])
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.04)

            var minorH = hDivs * 5
            for (var mh = 1; mh < minorH; mh++) {
                if (mh % 5 === 0) continue
                var my = Math.round(mh * h / minorH) + 0.5
                ctx.beginPath()
                ctx.moveTo(0, my)
                ctx.lineTo(w, my)
                ctx.stroke()
            }

            var minorV = vDivs * 5
            for (var mv = 1; mv < minorV; mv++) {
                if (mv % 5 === 0) continue
                var mx = Math.round(mv * w / minorV) + 0.5
                ctx.beginPath()
                ctx.moveTo(mx, 0)
                ctx.lineTo(mx, h)
                ctx.stroke()
            }
            ctx.setLineDash([])

            // ---- Zero baseline for bipolar waveforms ----
            if (root.minimumValue < 0 && root.maximumValue > 0) {
                var zeroY = h
                    - (-root.minimumValue / range) * h
                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.15)
                ctx.lineWidth = 1.5
                ctx.setLineDash([6, 4])
                ctx.beginPath()
                ctx.moveTo(0, Math.round(zeroY) + 0.5)
                ctx.lineTo(w, Math.round(zeroY) + 0.5)
                ctx.stroke()
                ctx.setLineDash([])
            }

            // ---- Data ----
            var data = root.samples
            if (!data || data.length < 2) {
                // No-signal flat line
                ctx.strokeStyle = Qt.rgba(
                    root.traceColor.r, root.traceColor.g,
                    root.traceColor.b, 0.2)
                ctx.lineWidth = 1
                ctx.setLineDash([8, 8])
                ctx.beginPath()
                ctx.moveTo(0, h * 0.65)
                ctx.lineTo(w, h * 0.65)
                ctx.stroke()
                return
            }

            var len = data.length
            var maxIdx = root.maxSamples - 1
            var sweepX = (len - 1) * w / maxIdx

            // Helper: sample index -> canvas coordinates
            function sampleToXY(idx) {
                var sx = idx * w / maxIdx
                var norm = (data[idx] - root.minimumValue) / range
                var sy = h - Math.max(0, Math.min(1, norm)) * h
                return { x: sx, y: sy }
            }

            // ---- Erase gap (dark region ahead of cursor) ----
            var gapW = w * 0.06
            var grad = ctx.createLinearGradient(
                sweepX, 0, sweepX + gapW, 0)
            grad.addColorStop(0.0, Qt.rgba(
                Colors.surface.r, Colors.surface.g,
                Colors.surface.b, 0.95))
            grad.addColorStop(1.0, Qt.rgba(
                Colors.surface.r, Colors.surface.g,
                Colors.surface.b, 0.0))
            ctx.fillStyle = grad
            ctx.fillRect(sweepX + 3, 0, gapW, h)

            // ---- Draw trace in 3 layers for depth ----

            // Layer 1: Faded tail (oldest data)
            var fadePoint = Math.max(0, len - 50)
            if (fadePoint > 1) {
                ctx.strokeStyle = Qt.rgba(
                    root.traceColor.r, root.traceColor.g,
                    root.traceColor.b, 0.25)
                ctx.lineWidth = 1.5
                ctx.lineJoin = "round"
                ctx.lineCap = "round"
                ctx.beginPath()
                var p0 = sampleToXY(0)
                ctx.moveTo(p0.x, p0.y)
                for (var a = 1; a < fadePoint; a++) {
                    var pa = sampleToXY(a)
                    ctx.lineTo(pa.x, pa.y)
                }
                ctx.stroke()
            }

            // Layer 2: Mid section (transitioning brightness)
            var midStart = Math.max(0, fadePoint)
            var hotStart = Math.max(0, len - 20)
            if (midStart < hotStart) {
                ctx.strokeStyle = Qt.rgba(
                    root.traceColor.r, root.traceColor.g,
                    root.traceColor.b, 0.55)
                ctx.lineWidth = 2.0
                ctx.lineJoin = "round"
                ctx.lineCap = "round"
                ctx.beginPath()
                var pm0 = sampleToXY(midStart)
                ctx.moveTo(pm0.x, pm0.y)
                for (var b = midStart + 1; b < hotStart; b++) {
                    var pb = sampleToXY(b)
                    ctx.lineTo(pb.x, pb.y)
                }
                ctx.stroke()
            }

            // Layer 3: Hot tip (newest ~20 samples)
            if (hotStart < len) {
                // Glow halo
                ctx.strokeStyle = Qt.rgba(
                    root.traceColor.r, root.traceColor.g,
                    root.traceColor.b, 0.12)
                ctx.lineWidth = 12
                ctx.lineJoin = "round"
                ctx.lineCap = "round"
                ctx.beginPath()
                var pg0 = sampleToXY(hotStart)
                ctx.moveTo(pg0.x, pg0.y)
                for (var c = hotStart + 1; c < len; c++) {
                    var pc = sampleToXY(c)
                    ctx.lineTo(pc.x, pc.y)
                }
                ctx.stroke()

                // Bright core trace
                ctx.strokeStyle = root.traceColor
                ctx.lineWidth = 3.0
                ctx.beginPath()
                var ph0 = sampleToXY(hotStart)
                ctx.moveTo(ph0.x, ph0.y)
                for (var d = hotStart + 1; d < len; d++) {
                    var pd = sampleToXY(d)
                    ctx.lineTo(pd.x, pd.y)
                }
                ctx.stroke()
            }

            // ---- Sweep cursor ----
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.7)
            ctx.lineWidth = 1.5
            ctx.beginPath()
            ctx.moveTo(Math.round(sweepX) + 0.5, 0)
            ctx.lineTo(Math.round(sweepX) + 0.5, h)
            ctx.stroke()

            // Cursor dot
            var tip = sampleToXY(len - 1)

            // Outer glow ring
            ctx.fillStyle = Qt.rgba(
                root.traceColor.r, root.traceColor.g,
                root.traceColor.b, 0.3)
            ctx.beginPath()
            ctx.arc(tip.x, tip.y, 7, 0, Math.PI * 2)
            ctx.fill()

            // Solid dot
            ctx.fillStyle = root.traceColor
            ctx.beginPath()
            ctx.arc(tip.x, tip.y, 4, 0, Math.PI * 2)
            ctx.fill()

            // White center
            ctx.fillStyle = "#FFFFFF"
            ctx.beginPath()
            ctx.arc(tip.x, tip.y, 1.5, 0, Math.PI * 2)
            ctx.fill()

            if (root.frozen && root.cursorA >= 0) {
                ctx.strokeStyle = Colors.warning
                ctx.lineWidth = 1.5
                ctx.setLineDash([4, 3])
                ctx.beginPath()
                ctx.moveTo(root.cursorA, 0)
                ctx.lineTo(root.cursorA, h)
                if (root.cursorB >= 0) {
                    ctx.moveTo(root.cursorB, 0)
                    ctx.lineTo(root.cursorB, h)
                }
                ctx.stroke()
                ctx.setLineDash([])
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.frozen
            onClicked: function(mouse) {
                if (root.cursorA < 0 || root.cursorB >= 0) {
                    root.cursorA = mouse.x
                    root.cursorB = -1
                } else {
                    root.cursorB = mouse.x
                }
                chartCanvas.requestPaint()
            }
        }
    }

    Text {
        visible: root.frozen && root.cursorA >= 0 && root.cursorB >= 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        text: {
            var a = root.valueAtCursor(root.cursorA)
            var b = root.valueAtCursor(root.cursorB)
            var dt = Math.abs(root.cursorB - root.cursorA)
                / Math.max(1, chartCanvas.width) * root.displaySeconds
            return "A " + a.toFixed(1) + "  B " + b.toFixed(1)
                + "  Delta " + Math.abs(b - a).toFixed(1)
                + (root.unit.length ? " " + root.unit : "")
                + " / " + dt.toFixed(2) + " s"
        }
        color: Colors.warning
        font.pixelSize: Typography.caption
        font.family: Typography.monoFamily
        z: 3
    }

    Row {
        visible: root.frozen
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 14
        anchors.bottomMargin: 8
        spacing: 6
        z: 3

        Repeater {
            model: [5, 10, 20]
            Rectangle {
                required property int modelData
                width: 38
                height: 24
                radius: 4
                color: root.displaySeconds === modelData
                    ? Colors.accentBlue : Colors.surfaceRaised
                Text {
                    anchors.centerIn: parent
                    text: modelData + "s"
                    color: Colors.textPrimary
                    font.pixelSize: 10
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.displaySeconds = parent.modelData
                }
            }
        }
    }

    onSamplesChanged: schedulePaint()
    onMinimumValueChanged: chartCanvas.requestPaint()
    onMaximumValueChanged: chartCanvas.requestPaint()
    onFrozenChanged: {
        if (!frozen) {
            cursorA = -1
            cursorB = -1
        }
        chartCanvas.requestPaint()
    }
}
