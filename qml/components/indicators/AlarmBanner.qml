import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../../styles"

Control {
    id: control
    property string headline: ""
    property string detail: ""

    clip: true

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
                font.pixelSize: 19
                font.bold: true
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
                font.pixelSize: 19
                font.bold: true
            }
        }
    }
}
