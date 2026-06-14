// -----------------------------------------------------------------------
// File: StatusPanel.qml
// Description: Combined ventilation mode and patient category display
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../../styles"

Control {
    id: root
    property string mode: "ASV"
    property string patientCategory: "Adult"

    padding: 18
    clip: true

    background: Rectangle {
        implicitHeight: 86
        implicitWidth: 280
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
    }

    contentItem: RowLayout {
        spacing: 18

        Control {

            background: Rectangle {
                implicitWidth: 85
                implicitHeight: 49
                radius: 8
                color: Colors.transparent
                border.color: Colors.disabled
            }

            contentItem: ColumnLayout {
                spacing: 0

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.mode
                    color: Colors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.DemiBold
                    font.pixelSize: Typography.subtitle
                }

                Control {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignVCenter
                    Layout.fillWidth: true
                    padding: 2

                    background: Rectangle {
                        radius: 0
                        bottomLeftRadius: 8
                        bottomRightRadius: 8
                        color: Colors.disabled
                    }

                    contentItem: Text {
                        text: "MODE"
                        color: Colors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.weight: Font.DemiBold
                        font.pixelSize: Typography.caption
                    }
                }
            }
        }

        Image {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            source: "qrc:/qml/assets/icons/signal.svg"

            Text {
                anchors.centerIn: parent
                text: root.patientCategory.charAt(0)
                color: Colors.textBackground
                font.pixelSize: Typography.bodyLarge
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Image {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            source: "qrc:/qml/assets/icons/person.svg"
            sourceSize: Qt.size(33, 27)
        }

        Image {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            source: "qrc:/qml/assets/icons/mic.svg"
            sourceSize: Qt.size(47, 19)
        }
    }
}
