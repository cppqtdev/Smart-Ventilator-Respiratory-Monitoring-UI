// -----------------------------------------------------------------------
// File: MetricTile.qml
// Description: Numeric value display tile for vital parameters
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import "../../styles"

Panel {
    id: root
    property string label: "Ppeak"
    property string value: "38"
    property string unit: "cmH2O"
    property string state: "normal"
    property string highValue: ""
    property string lowValue: ""
    property string trend: ""
    color: root.state === "critical" ? Colors.critical
         : root.state === "warning" ? Colors.warningBackground
         : Colors.surface
    clip: true

    // Flashing border for active alarm states
    border.color: root.state === "critical" ? Colors.critical
                : root.state === "warning" ? Colors.warning
                : Colors.line
    border.width: root.state === "normal" ? 1 : 2

    SequentialAnimation on opacity {
        running: root.state === "critical"
        loops: Animation.Infinite
        NumberAnimation { to: 0.6; duration: 500; easing.type: Easing.InOutQuad }
        NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
    }

    // Reset opacity when alarm clears
    onStateChanged: {
        if (root.state === "normal")
            root.opacity = 1.0
    }

    // Accessibility: shape indicator alongside color for color-blind users.
    // Triangle for critical, diamond for warning.
    Canvas {
        id: severityIndicator
        visible: root.state !== "normal"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 8
        anchors.topMargin: 8
        width: 18
        height: 18
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = Colors.textPrimary.toString()
            ctx.beginPath()
            if (root.state === "critical") {
                // Triangle for critical
                ctx.moveTo(width / 2, 0)
                ctx.lineTo(width, height)
                ctx.lineTo(0, height)
            } else {
                // Diamond for warning
                ctx.moveTo(width / 2, 0)
                ctx.lineTo(width, height / 2)
                ctx.lineTo(width / 2, height)
                ctx.lineTo(0, height / 2)
            }
            ctx.closePath()
            ctx.fill()
        }
        Connections {
            target: root
            function onStateChanged() {
                severityIndicator.requestPaint()
            }
        }
    }

    Text {
        id: labelText
        anchors.left: severityIndicator.visible
            ? severityIndicator.right : parent.left
        anchors.right: valueText.left
        anchors.top: parent.top
        anchors.leftMargin: 18
        anchors.rightMargin: 8
        anchors.topMargin: 16
        text: root.label
        color: Colors.textPrimary
        font.pixelSize: Math.max(16, Math.min(24, parent.height * 0.16))
        font.weight: Font.DemiBold
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
    }

    Text {
        id: valueText
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.top: parent.top
        anchors.topMargin: 18
        width: parent.width * 0.42
        text: root.value
        color: Colors.textPrimary
        font.pixelSize: Math.max(28, Math.min(48, parent.height * 0.30))
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignRight
        minimumPixelSize: 20
        fontSizeMode: Text.Fit
    }

    // Trend direction arrow for real-time parameter monitoring.
    Text {
        visible: root.trend === "rising" || root.trend === "falling"
        anchors.right: valueText.left
        anchors.rightMargin: 4
        anchors.top: valueText.top
        anchors.topMargin: 4
        text: root.trend === "rising" ? "\u2191" : "\u2193"
        color: root.trend === "rising" ? Colors.warning : Colors.success
        font.pixelSize: Math.max(16, Math.min(24, parent.height * 0.18))
        font.weight: Font.DemiBold
    }

    // High/low range sub-values (per Behance design)
    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.bottomMargin: 12
        visible: root.highValue.length > 0 || root.lowValue.length > 0
        spacing: 2

        Text {
            visible: root.highValue.length > 0
            text: root.highValue
            color: Colors.textMuted
            font.pixelSize: Math.max(12, Math.min(16, root.height * 0.11))
        }
        Text {
            visible: root.lowValue.length > 0
            text: root.lowValue
            color: Colors.textMuted
            font.pixelSize: Math.max(12, Math.min(16, root.height * 0.11))
        }
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        width: parent.width * 0.55
        text: root.unit
        color: Colors.textPrimary
        font.pixelSize: Math.max(14, Math.min(20, parent.height * 0.14))
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
    }
}
