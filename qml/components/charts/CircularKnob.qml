// -----------------------------------------------------------------------
// File: CircularKnob.qml
// Description: Circular rotary knob for parameter adjustment
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../../styles"

Control {
    id: root
    property string label: "Oxygen"
    property int value: 60
    property string unit: "%"
    property int minimum: 0
    property int maximum: 100
    signal valueChangedByUser(int value)
    clip: true

    contentItem: ColumnLayout {
        spacing: 0

        Text {
            id: labelText
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            text: root.label
            color: Colors.textLabel
            font.pixelSize: Typography.body
            font.weight: Font.DemiBold
        }

        Control {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Control {
                padding: 5
                height: 160
                width: 160
                anchors.centerIn: parent

                background: Rectangle {
                    radius: height / 2
                    color: Colors.surface
                }

                contentItem: Canvas {
                    id: knob
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
                        var ratio = (root.value - root.minimum) / (root.maximum - root.minimum)
                        var end = -Math.PI / 2 + (Math.PI * 2 * ratio)
                        ctx.arc(cx, cy, r, -Math.PI / 2, end)
                        ctx.stroke()
                    }
                    Connections { target: root; function onValueChanged() { knob.requestPaint() } }
                }

                Control {
                    anchors.centerIn: parent

                    contentItem: Column {
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.value
                            color: Colors.textValue
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Typography.titleLarge
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.unit
                            color: Colors.textUnit
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Typography.label
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            background: ColumnLayout {
                Item {
                    Layout.preferredHeight: 25
                }

                RowLayout {
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 60
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 7; color: Colors.accentBlueDark
                        topRightRadius: 0
                        bottomRightRadius: 0
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 7; color: Colors.accentBlueDark
                        topLeftRadius: 0
                        bottomLeftRadius: 0
                    }

                    Item {
                        Layout.preferredWidth: 60
                    }
                }

                Item {
                    Layout.preferredHeight: 25
                }
            }

            contentItem: RowLayout {
                spacing: 10

                Item {
                    Layout.preferredWidth: 55
                    Layout.fillHeight: true
                }

                ToolButton {
                    id: minusButton
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: "-"
                    palette.buttonText: Colors.textValue
                    font.pixelSize: Typography.titleLarge

                    onClicked: root.valueChangedByUser(Math.max(root.minimum, root.value - 1))
                    background: Item { implicitWidth: 40; implicitHeight: 40 }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                ToolButton {
                    id: plusButton
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    text: "+"
                    palette.buttonText: Colors.textValue
                    font.pixelSize: Typography.titleLarge
                    onClicked: root.valueChangedByUser(Math.min(root.maximum, root.value + 1))
                    background: Item { implicitWidth: 40; implicitHeight: 40 }
                }

                Item {
                    Layout.preferredWidth: 55
                    Layout.fillHeight: true
                }
            }
        }
    }
}
