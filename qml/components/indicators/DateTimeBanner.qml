import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../../styles"

Control {
    id: control

    property var clockData

    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    padding: 18

    background: Rectangle {
        implicitHeight: 86
        implicitWidth: 262
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
    }

    contentItem: RowLayout {
        spacing: 20

        Column {
            Layout.fillWidth: true

            Text {
                text: clockData ? clockData.dateText : "--\n--"
                color: "#9CA3AE"
                font.pixelSize: 16
            }

            Text {
                text: clockData ? clockData.timeText : "-- --"
                color: "#C2C5CB"
                font.pixelSize: 19
                font.bold: true
            }
        }

        Item { Layout.fillWidth: true }

        Image {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            source: "qrc:/qml/assets/icons/plug.svg"
            sourceSize: Qt.size(33, 27)
        }

        Image {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            source: "qrc:/qml/assets/icons/chanrge.svg"
            sourceSize: Qt.size(47, 19)
        }
    }
}
