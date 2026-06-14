// -----------------------------------------------------------------------
// File: ScreenLockOverlay.qml
// Description: Inactivity-triggered screen lock overlay for clinical security
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Controls.Basic

import "../../styles"
import "../buttons"

Rectangle {
    id: root

    property int timeoutSeconds: 300
    property bool locked: false

    signal unlocked()

    color: "#CC000000"
    visible: root.locked
    z: 1000

    // Inactivity timer that triggers the lock.
    Timer {
        id: inactivityTimer
        interval: root.timeoutSeconds * 1000
        running: !root.locked
        repeat: false
        onTriggered: root.locked = true
    }

    // Reset timer on any user interaction in the parent window.
    Connections {
        target: root.parent
        function onWidthChanged() { root.resetTimer() }
    }

    function resetTimer() {
        if (!root.locked) {
            inactivityTimer.restart()
        }
    }

    // Capture all mouse events when locked.
    MouseArea {
        anchors.fill: parent
        enabled: root.locked
        onClicked: {}
        onPressed: {}
    }

    Column {
        anchors.centerIn: parent
        spacing: 28

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Screen Locked"
            color: Colors.textPrimary
            font.pixelSize: Typography.headline
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Touch the button below to unlock"
            color: Colors.textSecondary
            font.pixelSize: Typography.body
            horizontalAlignment: Text.AlignHCenter
        }

        PrimaryButton {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 240
            height: 64
            text: "Unlock"
            buttonColor: Colors.accentBlue
            onClicked: {
                root.locked = false
                inactivityTimer.restart()
                root.unlocked()
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Timeout: " + root.timeoutSeconds + " seconds"
            color: Colors.textMuted
            font.pixelSize: Typography.caption
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
