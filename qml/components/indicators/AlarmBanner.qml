// -----------------------------------------------------------------------
// File: AlarmBanner.qml
// Description: Critical and warning alarm notification banner
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../../styles"

Control {
    id: control
    property string headline: ""
    property string detail: ""
    property bool flashing: true

    clip: true

    // IEC 60601-1-8: critical alarm visual indicator must flash.
    SequentialAnimation on opacity {
        running: control.visible && control.flashing
        loops: Animation.Infinite
        NumberAnimation {
            to: 0.35; duration: 350
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            to: 1.0; duration: 350
            easing.type: Easing.InOutQuad
        }
    }

    background: Item {
        width: control.width
        implicitHeight: 86
    }

    contentItem: ColumnLayout {
        spacing: 0

        Control {
            Layout.fillWidth: true
            padding: 10

            background: Rectangle {
                radius: Radius.medium
                bottomLeftRadius: 0
                bottomRightRadius: 0
                color: Colors.critical
            }

            contentItem: Text {
                text: headline
                color: Colors.textPrimary
                font.pixelSize: Typography.label
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }


        Control {
            Layout.fillWidth: true
            padding: 10

            background: Rectangle {
                topLeftRadius: 0
                topRightRadius: 0
                radius: Radius.medium
                color: Colors.warning
            }

            contentItem: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                text: detail
                color: Colors.textPrimary
                font.pixelSize: Typography.label
                font.weight: Font.DemiBold
            }
        }
    }
}
