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
    color: state === "critical" ? Colors.critical : Colors.surface
    clip: true

    // Accessibility: shape indicator alongside color for color-blind users.
    // Triangle for critical, no shape for normal.
    Canvas {
        id: severityIndicator
        visible: root.state === "critical"
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
            ctx.moveTo(width / 2, 0)
            ctx.lineTo(width, height)
            ctx.lineTo(0, height)
            ctx.closePath()
            ctx.fill()
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
