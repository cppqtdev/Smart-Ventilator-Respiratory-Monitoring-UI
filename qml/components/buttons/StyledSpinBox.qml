// -----------------------------------------------------------------------
// File: StyledSpinBox.qml
// Description: Themed spin box matching the ventilator UI design
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic
import "../../styles"

SpinBox {
    id: control
    height: 48
    editable: true
    font.pixelSize: Typography.body

    contentItem: TextInput {
        text: control.textFromValue(control.value, control.locale)
        font: control.font
        color: Colors.textPrimary
        selectionColor: Colors.accentBlue
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        radius: Radius.small
        topLeftRadius: 0
        bottomLeftRadius: 0
        color: control.up.pressed
            ? Colors.accentBlue : Colors.surfaceRaised

        Text {
            anchors.centerIn: parent
            text: "+"
            color: Colors.textPrimary
            font.pixelSize: Typography.body
            font.weight: Font.DemiBold
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: 40
        implicitHeight: 40
        radius: Radius.small
        topRightRadius: 0
        bottomRightRadius: 0
        color: control.down.pressed
            ? Colors.accentBlue : Colors.surfaceRaised

        Text {
            anchors.centerIn: parent
            text: "-"
            color: Colors.textPrimary
            font.pixelSize: Typography.body
            font.weight: Font.DemiBold
        }
    }

    background: Rectangle {
        implicitWidth: 140
        radius: Radius.small
        color: Colors.background
        border.color: Colors.line
    }
}
