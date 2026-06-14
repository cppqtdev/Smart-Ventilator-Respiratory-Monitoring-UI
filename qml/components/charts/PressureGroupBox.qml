import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GroupBox {
    id: root

    // Value
    property int value: 15
    property int minimumValue: 0
    property int maximumValue: 100
    property int stepSize: 1
    property string unit: "cmH2O"

    // GroupBox
    property string labelText: ""
    property color titleColor: "#CDCFD5"
    property int titlePixelSize: 21
    property color groupBackgroundColor: "transparent"

    // Size
    property real sideButtonWidth: 54
    property real sideButtonHeight: 100
    property real gaugeSize: 160
    property real controlSpacing: 0

    // Side button style
    property color sideButtonColor: "#236AB2"
    property color sideButtonTextColor: "white"
    property int sideButtonTextPixelSize: 24
    property real sideButtonCornerRadius: 12
    property real sideButtonCurveDepth: 32

    // Gauge style
    property color progressColor: "#4D8EFF"
    property color trackColor: "#59647C"
    property color valueColor: "#D7D9DC"
    property color unitColor: "#6C7586"
    property color centerBackgroundColor: "#00000000"

    property real ringThickness: 12
    property real ringPadding: 8
    property int valuePixelSize: 34
    property int unitPixelSize: 19

    signal valueChangedByUser(int value)

    title: root.labelText
    palette.windowText: root.titleColor
    palette.mid: "transparent"
    font.pixelSize: root.titlePixelSize
    font.bold: true
    padding: 0
    spacing: 5

    background: Rectangle {
        color: root.groupBackgroundColor
        radius: 0
        border.width: 0
    }

    RowLayout {
        anchors.fill: parent
        spacing: root.controlSpacing

        CurvedSideButton {
            Layout.preferredWidth: root.sideButtonWidth
            Layout.preferredHeight: root.sideButtonHeight
            Layout.alignment: Qt.AlignVCenter

            edge: CurvedSideButton.Left
            backgroundColor: root.sideButtonColor
            textColor: root.sideButtonTextColor
            textPixelSize: root.sideButtonTextPixelSize
            cornerRadius: root.sideButtonCornerRadius
            curveDepth: root.sideButtonCurveDepth
            text: "-"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.value = Math.max(root.minimumValue, root.value - root.stepSize)
                    root.valueChangedByUser(root.value)
                }
            }
        }

        PressureControl {
            Layout.preferredWidth: root.gaugeSize
            Layout.preferredHeight: root.gaugeSize
            Layout.alignment: Qt.AlignVCenter

            value: root.value
            minimumValue: root.minimumValue
            maximumValue: root.maximumValue
            unitText: root.unit

            progressColor: root.progressColor
            trackColor: root.trackColor
            ringThickness: root.ringThickness
            ringPadding: root.ringPadding

            valueBold: true
            valueColor: root.valueColor
            unitColor: root.unitColor
            valuePixelSize: root.valuePixelSize
            unitPixelSize: root.unitPixelSize
            centerBackgroundColor: root.centerBackgroundColor
        }

        CurvedSideButton {
            Layout.preferredWidth: root.sideButtonWidth
            Layout.preferredHeight: root.sideButtonHeight
            Layout.alignment: Qt.AlignVCenter

            edge: CurvedSideButton.Right
            backgroundColor: root.sideButtonColor
            textColor: root.sideButtonTextColor
            textPixelSize: root.sideButtonTextPixelSize
            cornerRadius: root.sideButtonCornerRadius
            curveDepth: root.sideButtonCurveDepth
            text: "+"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.value = Math.min(root.maximumValue, root.value + root.stepSize)
                    root.valueChangedByUser(root.value)
                }
            }
        }
    }
}
