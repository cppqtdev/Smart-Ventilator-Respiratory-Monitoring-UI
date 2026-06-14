pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: BottomNavigation.qml
// Description: Eight-tab persistent bottom navigation bar
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import "../../styles"
import "../buttons"

TabBar {
    id: root
    property string currentScreen: "standby"
    signal navigate(string screen)

    background: Item {
        width: parent.width
        height: 74
    }

    spacing: 10

    NavTabButton {
        text: "Monitoring"
        screen: "monitoring"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "Controls"
        screen: "controls"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "System"
        screen: "system"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "Layout"
        screen: "layout"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "Events"
        screen: "events"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "Alarms"
        screen: "alarms"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "Tools"
        screen: "tools"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "Modes"
        screen: "modes"
        onClicked: root.navigate(screen)
    }

    component NavTabButton: PrefsTabButton {
        property string screen: ""
        font.pixelSize: Typography.label
        font.weight: Font.Bold
    }
}
