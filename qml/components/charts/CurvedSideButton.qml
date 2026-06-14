// -----------------------------------------------------------------------
// File: CurvedSideButton.qml
// Description: Shape-based curved button for gauge side controls
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

import "../../styles"

Item {
    id: root

    enum Edge {
        Left,
        Right,
        Top,
        Bottom
    }

    property int edge: CurvedSideButton.Left

    property color backgroundColor: Colors.accentCyan
    property color borderColor: "transparent"
    property real borderWidth: 0

    property real cornerRadius: 12
    property real curveDepth: 50

    property string text: ""
    property color textColor: "white"
    property int textPixelSize: 24

    width: 160
    height: 220

    Loader {
        anchors.fill: parent

        sourceComponent: {
            switch(root.edge) {
            case CurvedSideButton.Left:
                return leftShape

            case CurvedSideButton.Right:
                return rightShape

            case CurvedSideButton.Top:
                return topShape

            case CurvedSideButton.Bottom:
                return bottomShape
            }

            return leftShape
        }
    }


    Control {
        visible: edge === CurvedSideButton.Right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 14

        MouseArea {
            anchors.fill: parent
        }

        contentItem: Text {
            text: root.text
            color: root.textColor
            font.pixelSize: root.textPixelSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }


    Control {
        visible: edge === CurvedSideButton.Left
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14

        MouseArea {
            anchors.fill: parent
        }

        contentItem: Text {
            text: root.text
            color: root.textColor
            font.pixelSize: root.textPixelSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    //
    // LEFT
    //

    Component {
        id: leftShape

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                fillColor: root.backgroundColor
                strokeColor: root.borderColor
                strokeWidth: root.borderWidth

                startX: root.cornerRadius
                startY: 0

                PathQuad {
                    x: 0
                    y: root.cornerRadius
                    controlX: 0
                    controlY: 0
                }

                PathLine {
                    x: 0
                    y: root.height - root.cornerRadius
                }

                PathQuad {
                    x: root.cornerRadius
                    y: root.height
                    controlX: 0
                    controlY: root.height
                }

                PathLine {
                    x: root.width
                    y: root.height
                }

                PathCubic {
                    x: root.width
                    y: 0

                    control1X: root.curveDepth
                    control1Y: root.height * 0.75

                    control2X: root.curveDepth
                    control2Y: root.height * 0.25
                }

                PathLine {
                    x: root.cornerRadius
                    y: 0
                }
            }
        }
    }

    //
    // RIGHT
    //

    Component {
        id: rightShape

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                fillColor: root.backgroundColor
                strokeColor: root.borderColor
                strokeWidth: root.borderWidth

                startX: root.width - root.cornerRadius
                startY: 0

                PathQuad {
                    x: root.width
                    y: root.cornerRadius
                    controlX: root.width
                    controlY: 0
                }

                PathLine {
                    x: root.width
                    y: root.height - root.cornerRadius
                }

                PathQuad {
                    x: root.width - root.cornerRadius
                    y: root.height
                    controlX: root.width
                    controlY: root.height
                }

                PathLine {
                    x: 0
                    y: root.height
                }

                PathCubic {
                    x: 0
                    y: 0

                    control1X: root.width - root.curveDepth
                    control1Y: root.height * 0.75

                    control2X: root.width - root.curveDepth
                    control2Y: root.height * 0.25
                }

                PathLine {
                    x: root.width - root.cornerRadius
                    y: 0
                }
            }
        }
    }

    //
    // TOP
    //

    Component {
        id: topShape

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                fillColor: root.backgroundColor
                strokeColor: root.borderColor
                strokeWidth: root.borderWidth

                startX: 0
                startY: root.cornerRadius

                PathQuad {
                    x: root.cornerRadius
                    y: 0
                    controlX: 0
                    controlY: 0
                }

                PathCubic {
                    x: root.width - root.cornerRadius
                    y: 0

                    control1X: root.width * 0.30
                    control1Y: root.curveDepth

                    control2X: root.width * 0.70
                    control2Y: root.curveDepth
                }

                PathQuad {
                    x: root.width
                    y: root.cornerRadius
                    controlX: root.width
                    controlY: 0
                }

                PathLine {
                    x: root.width
                    y: root.height
                }

                PathLine {
                    x: 0
                    y: root.height
                }

                PathLine {
                    x: 0
                    y: root.cornerRadius
                }
            }
        }
    }

    //
    // BOTTOM
    //

    Component {
        id: bottomShape

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                fillColor: root.backgroundColor
                strokeColor: root.borderColor
                strokeWidth: root.borderWidth

                startX: 0
                startY: 0

                PathLine {
                    x: root.width
                    y: 0
                }

                PathLine {
                    x: root.width
                    y: root.height - root.cornerRadius
                }

                PathQuad {
                    x: root.width - root.cornerRadius
                    y: root.height
                    controlX: root.width
                    controlY: root.height
                }

                PathCubic {
                    x: root.cornerRadius
                    y: root.height

                    control1X: root.width * 0.70
                    control1Y: root.height - root.curveDepth

                    control2X: root.width * 0.30
                    control2Y: root.height - root.curveDepth
                }

                PathQuad {
                    x: 0
                    y: root.height - root.cornerRadius
                    controlX: 0
                    controlY: root.height
                }

                PathLine {
                    x: 0
                    y: 0
                }
            }
        }
    }
}
