pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"
import "../components/buttons"

Control {
    id: root
    property int selectedLayout: 1

    background: Rectangle {
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
        border.width: 1
    }

    contentItem: Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: layoutGrid.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Control {
            width: root.width
            padding: 24

            contentItem: Grid {
                id: layoutGrid
                columns: 3
                spacing: 34

                Repeater {
                    model: 5
                    Column {
                        id: layoutDelegate
                        required property int index
                        width: (layoutGrid.width - layoutGrid.spacing * 2) / 3
                        spacing: 18

                        PrimaryButton {
                            width: parent.width
                            text: "Layout " + (layoutDelegate.index + 1)
                            buttonColor: root.selectedLayout === layoutDelegate.index + 1 ? Colors.accentBlue : "#9AA2AE"
                            onClicked: root.selectedLayout = layoutDelegate.index + 1
                        }

                        Rectangle {
                            width: parent.width
                            height: 180
                            radius: Radius.small
                            color: "transparent"
                            border.color: Colors.textSecondary
                            border.width: 2

                            Repeater {
                                model: layoutDelegate.index + 1
                                Rectangle {
                                    required property int index
                                    x: index % 2 === 0 ? 0 : parent.width / 2
                                    y: index < 2 ? parent.height * 0.25 : parent.height * 0.55
                                    width: parent.width / 2
                                    height: 2
                                    color: Colors.textSecondary
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
