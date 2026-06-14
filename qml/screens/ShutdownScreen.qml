// -----------------------------------------------------------------------
// File: ShutdownScreen.qml
// Description: Clinical stop confirmation screen for safe ventilator shutdown
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

    property var ventilatorData
    property var alarmData

    signal shutdownConfirmed()
    signal shutdownCancelled()

    contentItem: Item {
        // HARDWARE: Before confirming shutdown, the system should:
        //   1. Verify patient is disconnected or on alternative support
        //   2. Log final ventilation summary to audit trail
        //   3. Save operating hours to persistent storage
        //   4. Close all valves and de-energize actuators
        //   5. Archive session data for clinical records

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.5, 680)
            spacing: Spacing.panelGap

            // Warning panel
            Panel {
                Layout.fillWidth: true
                Layout.preferredHeight: warningContent.implicitHeight + 80

                ColumnLayout {
                    id: warningContent
                    anchors.fill: parent
                    anchors.margins: Spacing.cardPadding
                    spacing: 24

                    Text {
                        Layout.fillWidth: true
                        text: "Stop Ventilation"
                        color: Colors.critical
                        font.pixelSize: Typography.title
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 2
                        color: Colors.line
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "You are about to stop mechanical ventilation.\n"
                            + "Ensure the patient has been safely disconnected "
                            + "or transitioned to an alternative ventilatory "
                            + "support before proceeding."
                        color: Colors.textSecondary
                        font.pixelSize: Typography.bodyLarge
                        font.family: Typography.monoFamily
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 2
                        color: Colors.line
                    }

                    // Active alarm summary
                    Text {
                        Layout.fillWidth: true
                        text: root.alarmData && root.alarmData.active
                            ? "Active alarm: " + root.alarmData.headline
                            : "No active alarms"
                        color: root.alarmData && root.alarmData.active
                            ? Colors.warning
                            : Colors.success
                        font.pixelSize: Typography.body
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Current mode and runtime
                    Text {
                        Layout.fillWidth: true
                        text: "Current mode: "
                            + (root.ventilatorData
                                ? root.ventilatorData.mode
                                : "--")
                        color: Colors.textMuted
                        font.pixelSize: Typography.body
                        font.family: Typography.monoFamily
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                spacing: Spacing.panelGap

                PrimaryButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "Cancel"
                    buttonColor: Colors.disabled
                    onClicked: root.shutdownCancelled()
                }

                PrimaryButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "Confirm Stop"
                    buttonColor: Colors.critical
                    onClicked: {
                        if (root.ventilatorData) {
                            root.ventilatorData.stopVentilation()
                        }
                        root.shutdownConfirmed()
                    }
                }
            }
        }
    }
}
