// -----------------------------------------------------------------------
// File: DateTimeBanner.qml
// Description: Real-time clock display with battery and connectivity status icons
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
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
                color: Colors.textMuted
                font.pixelSize: Typography.small
            }

            Text {
                text: clockData ? clockData.timeText : "-- --"
                color: Colors.textLight
                font.pixelSize: Typography.label
                font.weight: Font.DemiBold
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
            source: "qrc:/qml/assets/icons/charge.svg"
            sourceSize: Qt.size(47, 19)
        }
    }
}
