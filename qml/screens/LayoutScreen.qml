pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: LayoutScreen.qml
// Description: Monitoring layout preset selection
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../styles"
import "../components/cards"
import "../components/buttons"

Control {
    id: root
    property int selectedLayout: 1
    property int appliedLayout: 1

    readonly property var layoutNames: [
        "Standard",
        "Dual Waveform",
        "Triple Panel",
        "Quad View",
        "Full Overview"
    ]

    readonly property var layoutDescriptions: [
        "Single waveform with full metrics panel",
        "Pressure and flow waveforms side by side",
        "Three waveforms with compact metrics",
        "Four-quadrant waveform and vitals view",
        "All waveforms with lung visualization"
    ]

    background: Rectangle {
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
        border.width: 1
    }

    contentItem: Column {
        spacing: 20
        padding: 24

        Row {
            width: parent.width - 48
            spacing: 18

            Text {
                text: "Monitoring Layout"
                color: Colors.textPrimary
                font.pixelSize: Typography.title
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 20; height: 1 }

            Text {
                text: "Active: " + root.layoutNames[root.appliedLayout - 1]
                color: Colors.successBright
                font.pixelSize: Typography.body
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { Layout.fillWidth: true; width: 10; height: 1 }

            PrimaryButton {
                width: 200
                height: 48
                text: root.selectedLayout === root.appliedLayout
                    ? "Applied" : "Apply Layout"
                buttonColor: root.selectedLayout === root.appliedLayout
                    ? Colors.disabled : Colors.accentBlue
                onClicked: root.appliedLayout = root.selectedLayout
            }
        }

        Flickable {
            width: parent.width - 48
            height: parent.height - 100
            contentWidth: width
            contentHeight: layoutGrid.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            Grid {
                id: layoutGrid
                width: parent.width
                columns: 3
                spacing: 28

                Repeater {
                    model: 5
                    Column {
                        id: layoutDelegate
                        required property int index
                        width: (layoutGrid.width - layoutGrid.spacing * 2) / 3
                        spacing: 14

                        PrimaryButton {
                            width: parent.width
                            text: root.layoutNames[layoutDelegate.index]
                            buttonColor: root.selectedLayout
                                === layoutDelegate.index + 1
                                ? Colors.accentBlue
                                : Colors.buttonTest
                            onClicked: {
                                root.selectedLayout = layoutDelegate.index + 1
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 160
                            radius: Radius.small
                            color: root.appliedLayout === layoutDelegate.index + 1
                                ? Colors.surfaceRaised : "transparent"
                            border.color: root.selectedLayout
                                === layoutDelegate.index + 1
                                ? Colors.accentBlue
                                : Colors.textSecondary
                            border.width: root.selectedLayout
                                === layoutDelegate.index + 1 ? 3 : 1

                            // Layout preview lines
                            Repeater {
                                model: layoutDelegate.index + 1
                                Rectangle {
                                    required property int index
                                    x: index % 2 === 0
                                        ? 0 : parent.width / 2
                                    y: index < 2
                                        ? parent.height * 0.25
                                        : parent.height * 0.55
                                    width: parent.width / 2
                                    height: 2
                                    color: Colors.textSecondary
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: root.layoutDescriptions[
                                layoutDelegate.index]
                            color: Colors.textMuted
                            font.pixelSize: Typography.caption
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
