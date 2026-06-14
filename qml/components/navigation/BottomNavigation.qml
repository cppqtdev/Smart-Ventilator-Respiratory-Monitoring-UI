pragma ComponentBehavior: Bound

import QtQuick 2.15
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
        font.pixelSize: 18
        font.weight: Font.Bold
    }
}
