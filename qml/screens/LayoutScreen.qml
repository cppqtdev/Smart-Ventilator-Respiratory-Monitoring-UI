pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls.Basic
import "../styles"
import "../components/cards"
import "../components/buttons"

Item {
    id: root
    property int selectedLayout: 1

    Panel {
        anchors.fill: parent
        clip: true

        Flickable {
            anchors.fill: parent
            anchors.margins: 28
            contentWidth: width
            contentHeight: layoutGrid.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Grid {
                id: layoutGrid
                width: parent.width
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
                            height: 66
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
