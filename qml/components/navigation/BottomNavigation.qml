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

    spacing: 6

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
        text: "Trends"
        screen: "trends"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "Loops"
        screen: "loops"
        onClicked: root.navigate(screen)
    }

    NavTabButton {
        text: "Clinical"
        screen: "clinical"
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
        text: "Target"
        screen: "target"
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

    NavTabButton {
        text: "Settings"
        screen: "settings"
        onClicked: root.navigate(screen)
    }

    component NavTabButton: PrefsTabButton {
        property string screen: ""
        checked: root.currentScreen === screen
        font.pixelSize: Typography.small
        font.weight: Font.Bold
    }
}
