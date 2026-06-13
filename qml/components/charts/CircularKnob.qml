import QtQuick 2.15
import QtQuick.Controls.Basic
import "../../styles"

Item {
    id: root
    property string label: "Oxygen"
    property int value: 60
    property string unit: "%"
    property int minimum: 0
    property int maximum: 100
    signal valueChangedByUser(int value)
    clip: true

    Text {
        id: titleText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        text: root.label
        color: Colors.textPrimary
        font.pixelSize: Math.max(16, Math.min(28, root.height * 0.13))
        font.bold: true
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
    }

    Button {
        id: minusButton
        width: Math.max(52, Math.min(72, root.width * 0.18))
        height: Math.max(52, Math.min(72, root.height * 0.30))
        anchors.left: parent.left
        anchors.verticalCenter: knob.verticalCenter
        text: "-"
        font.pixelSize: Math.max(24, Math.min(34, height * 0.48))
        onClicked: root.valueChangedByUser(Math.max(root.minimum, root.value - 1))
        background: Rectangle { radius: 7; color: "#236AB2" }
        contentItem: Text { text: minusButton.text; color: "white"; font: minusButton.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
    }

    Canvas {
        id: knob
        width: Math.max(88, Math.min(root.width - minusButton.width * 2 - 32, root.height - titleText.height - 10))
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        onPaint: {
            var ctx = getContext("2d")
            var cx = width / 2
            var cy = height / 2
            var r = width * 0.38
            ctx.clearRect(0, 0, width, height)
            ctx.lineWidth = width * 0.08
            ctx.strokeStyle = Colors.disabled
            ctx.beginPath()
            ctx.arc(cx, cy, r, -Math.PI / 2, Math.PI * 1.5)
            ctx.stroke()
            ctx.strokeStyle = Colors.accentBlue
            ctx.beginPath()
            var end = -Math.PI / 2 + (Math.PI * 2 * (root.value - root.minimum) / (root.maximum - root.minimum))
            ctx.arc(cx, cy, r, -Math.PI / 2, end)
            ctx.stroke()
        }
        Connections { target: root; function onValueChanged() { knob.requestPaint() } }
    }

    Text {
        anchors.centerIn: knob
        text: root.value + "\n" + root.unit
        color: Colors.textPrimary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        width: knob.width * 0.72
        height: knob.height * 0.62
        font.pixelSize: Math.max(18, Math.min(36, knob.width * 0.18))
        font.bold: true
        minimumPixelSize: 14
        fontSizeMode: Text.Fit
        wrapMode: Text.Wrap
        lineHeight: 0.82
    }

    Button {
        id: plusButton
        width: minusButton.width
        height: minusButton.height
        anchors.right: parent.right
        anchors.verticalCenter: knob.verticalCenter
        text: "+"
        font.pixelSize: minusButton.font.pixelSize
        onClicked: root.valueChangedByUser(Math.min(root.maximum, root.value + 1))
        background: Rectangle { radius: 7; color: "#236AB2" }
        contentItem: Text { text: plusButton.text; color: "white"; font: plusButton.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
    }
}
