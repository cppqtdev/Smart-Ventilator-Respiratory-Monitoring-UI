// -----------------------------------------------------------------------
// File: LoginScreen.qml
// Description: Operator authentication screen with PIN entry and role selection
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

    signal loginAccepted(string role)

    property var userControllerData
    property string enteredUsername: "admin"
    property string enteredPin: ""
    property string errorMessage: ""

    // PRODUCTION: Implement account lockout after 3 failed attempts
    // per IEC 62443 (industrial cybersecurity).

    function attemptLogin() {
        if (root.enteredPin.length < 4) {
            root.errorMessage = "PIN must be 4 digits"
            return
        }
        if (!root.userControllerData) {
            root.errorMessage = "System not ready"
            return
        }
        if (root.userControllerData.login(
                root.enteredUsername, root.enteredPin)) {
            root.errorMessage = ""
            root.enteredPin = ""
            root.loginAccepted(root.userControllerData.currentRole)
        } else {
            root.errorMessage = "Invalid username or PIN"
            root.enteredPin = ""
        }
    }

    function appendDigit(digit) {
        if (root.enteredPin.length < 4) {
            root.enteredPin += digit
            root.errorMessage = ""
        }
    }

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.36, 520)
            spacing: 24

            // Title
            Text {
                Layout.fillWidth: true
                text: "Operator Login"
                color: Colors.textPrimary
                font.pixelSize: Typography.title
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }

            // Quick user selection buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: ["admin", "doctor", "nurse", "service"]
                    PrefsTabButton {
                        id: quickBtn
                        required property string modelData
                        Layout.fillWidth: true
                        text: quickBtn.modelData
                        checked: root.enteredUsername === quickBtn.modelData
                        onClicked: {
                            root.enteredUsername = quickBtn.modelData
                            root.enteredPin = ""
                            root.errorMessage = ""
                        }
                    }
                }
            }

            // PIN display
            Panel {
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Text {
                    anchors.centerIn: parent
                    text: {
                        var dots = ""
                        for (var i = 0; i < root.enteredPin.length; i++)
                            dots += "\u25CF  "
                        for (var j = root.enteredPin.length; j < 4; j++)
                            dots += "\u25CB  "
                        return dots.trim()
                    }
                    color: Colors.textPrimary
                    font.pixelSize: Typography.title
                    font.letterSpacing: 8
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Error message
            Text {
                Layout.fillWidth: true
                text: root.errorMessage
                color: Colors.critical
                font.pixelSize: Typography.body
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                visible: root.errorMessage.length > 0
            }

            // Numeric keypad
            Grid {
                Layout.alignment: Qt.AlignHCenter
                columns: 3
                spacing: 12

                Repeater {
                    model: ["1","2","3","4","5","6","7","8","9","C","0","OK"]

                    PrimaryButton {
                        id: keyButton
                        required property string modelData
                        width: 100
                        height: 64
                        text: keyButton.modelData
                        buttonColor: {
                            if (keyButton.modelData === "OK")
                                return Colors.success
                            if (keyButton.modelData === "C")
                                return Colors.critical
                            return Colors.surfaceRaised
                        }
                        onClicked: {
                            if (keyButton.modelData === "OK")
                                root.attemptLogin()
                            else if (keyButton.modelData === "C")
                                root.enteredPin = ""
                            else
                                root.appendDigit(keyButton.modelData)
                        }
                    }
                }
            }

            // Demo hint
            Text {
                Layout.fillWidth: true
                text: "Default PINs -- admin: 0000 | doctor: 1234 | nurse: 5678 | service: 9999"
                color: Colors.textMuted
                font.pixelSize: Typography.caption
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
