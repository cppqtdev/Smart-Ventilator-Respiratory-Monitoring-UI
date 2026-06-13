pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import "../../styles"

Rectangle {
    id: root
    property string currentScreen: "standby"
    signal navigate(string screen)
    color: "transparent"

    Row {
        anchors.fill: parent
        spacing: 16
        Repeater {
            model: [
                { label: "Monitoring", screen: "monitoring" },
                { label: "Controls", screen: "controls" },
                { label: "System", screen: "system" },
                { label: "Layout", screen: "layout" },
                { label: "Events", screen: "events" },
                { label: "Alarms", screen: "alarms" },
                { label: "Tools", screen: "tools" },
                { label: "Modes", screen: "modes" }
            ]

            Button {
                id: navButton
                required property var modelData
                width: (root.width - 16 * 7) / 8
                height: parent.height
                text: navButton.modelData.label
                font.pixelSize: Math.max(18, root.height * 0.3)
                font.bold: true
                onClicked: root.navigate(navButton.modelData.screen)
                background: Rectangle {
                    radius: Radius.small
                    color: root.currentScreen === navButton.modelData.screen ? Colors.accentBlue : "#236AB2"
                    opacity: enabled ? 1 : 0.55
                }
                contentItem: Text {
                    text: navButton.text
                    color: Colors.textPrimary
                    font: navButton.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }
}
