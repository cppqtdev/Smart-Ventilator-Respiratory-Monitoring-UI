import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: root

    // Size
    width: 340
    height: 340

    // Value
    property int value: 15
    property int minimumValue: 0
    property int maximumValue: 30
    property string unitText: "cmH2O"

    // Ring styling
    property color progressColor: "#2497FF"
    property color trackColor: "#647391"
    property real ringThickness: 32
    property real ringPadding: 8
    property bool roundedCaps: true

    // Center styling
    property color centerBackgroundColor: "transparent"

    // Value text styling
    property color valueColor: "white"
    property int valuePixelSize: 84
    property bool valueBold: false

    // Unit text styling
    property color unitColor: "#7C8AA6"
    property int unitPixelSize: 34
    property bool unitBold: false

    // Layout
    property real textSpacing: 2
    property real textVerticalOffset: 0

    readonly property real progress:
        Math.max(0,
                 Math.min(1,
                          (value - minimumValue)
                          / (maximumValue - minimumValue)))

    Canvas {
        id: ringCanvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const cx = width / 2
            const cy = height / 2

            const radius =
                         Math.min(width, height) / 2
                         - root.ringThickness / 2
                         - root.ringPadding

            // Track
            ctx.beginPath()
            ctx.strokeStyle = root.trackColor
            ctx.lineWidth = root.ringThickness
            ctx.arc(cx, cy, radius, 0, Math.PI * 2)
            ctx.stroke()

            // Progress
            ctx.beginPath()
            ctx.strokeStyle = root.progressColor
            ctx.lineWidth = root.ringThickness

            if (root.roundedCaps)
                ctx.lineCap = "round"

            const startAngle = -Math.PI / 2
            const endAngle =
                           startAngle
                           + Math.PI * 2 * root.progress

            ctx.arc(cx, cy, radius, startAngle, endAngle)
            ctx.stroke()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    Connections {
        target: root

        function onValueChanged() {
            ringCanvas.requestPaint()
        }

        function onProgressColorChanged() {
            ringCanvas.requestPaint()
        }

        function onTrackColorChanged() {
            ringCanvas.requestPaint()
        }

        function onRingThicknessChanged() {
            ringCanvas.requestPaint()
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width - root.ringThickness * 2
        height: width
        radius: width / 2
        color: root.centerBackgroundColor
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.textVerticalOffset
        spacing: root.textSpacing

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.value
            color: root.valueColor

            font.pixelSize: root.valuePixelSize
            font.bold: root.valueBold
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.unitText
            color: root.unitColor

            font.pixelSize: root.unitPixelSize
            font.bold: root.unitBold
        }
    }
}
