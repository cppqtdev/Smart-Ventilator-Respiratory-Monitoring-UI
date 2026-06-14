pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: SettingsScreen.qml
// Description: Application settings with user management, security, and display config
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import "../styles"
import "../components/cards"
import "../components/buttons"
import "../components/charts"

Page {
    id: root
    property var appSettingsData
    property var userControllerData
    property var clockData
    property int currentTab: 0

    // Create user form state
    property string formUsername: ""
    property string formPin: ""
    property string formRole: "Nurse"
    property string formFullName: ""
    property string formMessage: ""
    property bool formIsError: false

    // Password change form state
    property string pwdTargetUser: ""
    property string pwdNewPin: ""
    property string pwdConfirmPin: ""
    property string pwdMessage: ""
    property bool pwdIsError: false

    padding: 0

    function selectTab(tab) { root.currentTab = tab }

    function clearForm() {
        root.formUsername = ""
        root.formPin = ""
        root.formRole = "Nurse"
        root.formFullName = ""
        root.formMessage = ""
        root.formIsError = false
    }

    background: Rectangle {
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
        border.width: 1
    }

    header: Control {
        padding: 20

        contentItem: RowLayout {
            spacing: 14

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Users"
                checked: root.currentTab === 0
                onClicked: root.selectTab(0)
            }
            PrefsTabButton {
                Layout.fillWidth: true
                text: "Change PIN"
                checked: root.currentTab === 1
                onClicked: root.selectTab(1)
            }
            PrefsTabButton {
                Layout.fillWidth: true
                text: "Security"
                checked: root.currentTab === 2
                onClicked: root.selectTab(2)
            }
            PrefsTabButton {
                Layout.fillWidth: true
                text: "About"
                checked: root.currentTab === 3
                onClicked: root.selectTab(3)
            }
        }
    }

    contentItem: Flickable {
        contentWidth: width
        contentHeight: contentCol.height + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Control {
            width: root.width
            leftPadding: 24
            rightPadding: 24
            topPadding: 24

            contentItem: ColumnLayout {
                id: contentCol
                spacing: 20

                // =============================================================
                // TAB 0: User Management
                // =============================================================

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 0

                    contentItem: Column {
                        spacing: 18

                        Text {
                            text: "User Management"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.title
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            text: root.userControllerData
                                  && root.userControllerData.currentRole === "Admin"
                                  ? "Create, edit, and delete user accounts."
                                  : "Only Admin users can manage accounts. Current role: "
                                    + (root.userControllerData ? root.userControllerData.currentRole : "--")
                            color: Colors.textSecondary
                            font.pixelSize: Typography.body
                            wrapMode: Text.WordWrap
                        }

                        // --- Create New User Form (Admin only) ---
                        Control {
                            padding: 24
                            visible: root.userControllerData && root.userControllerData.currentRole === "Admin"
                            width: parent.width

                            background: Rectangle {
                                radius: Radius.medium
                                color: Colors.surface
                                border.color: Colors.line
                                border.width: 1
                            }

                            contentItem: Column {
                                id: createCol
                                spacing: 16

                                Text {
                                    text: "Create New User"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.subtitle
                                    font.weight: Font.DemiBold
                                }

                                Control {
                                    width: parent.width

                                    contentItem: RowLayout {
                                        spacing: 16

                                        // Left column: Username + Full Name
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 12

                                            Text {
                                                Layout.fillWidth: true
                                                text: "Username"
                                                color: Colors.textMuted
                                                font.pixelSize: Typography.caption
                                            }

                                            TextField {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 48
                                                leftPadding: 14
                                                placeholderText: "Enter username (min 3 chars)"
                                                text: root.formUsername
                                                onTextChanged: root.formUsername = text
                                                color: Colors.textPrimary
                                                font.pixelSize: Typography.body

                                                background: Rectangle {
                                                    radius: Radius.small
                                                    color: Colors.background
                                                    border.color: Colors.line
                                                }
                                            }

                                            Item { width: 1; height: 4 }

                                            Text {
                                                Layout.fillWidth: true
                                                text: "Full Name"
                                                color: Colors.textMuted
                                                font.pixelSize: Typography.caption
                                            }

                                            TextField {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 48
                                                leftPadding: 14
                                                placeholderText: "Dr. John Smith"
                                                text: root.formFullName
                                                onTextChanged: root.formFullName = text
                                                color: Colors.textPrimary
                                                font.pixelSize: Typography.body

                                                background: Rectangle {
                                                    radius: Radius.small
                                                    color: Colors.background
                                                    border.color: Colors.line
                                                }
                                            }
                                        }

                                        // Right column: PIN + Role
                                        Control {
                                            Layout.fillWidth: true

                                            contentItem: ColumnLayout {
                                                spacing: 12

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: "PIN (4 digits)"
                                                    color: Colors.textMuted
                                                    font.pixelSize: Typography.caption
                                                }

                                                TextField {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 48
                                                    leftPadding: 14
                                                    placeholderText: "0000"
                                                    text: root.formPin
                                                    onTextChanged: root.formPin = text
                                                    maximumLength: 4
                                                    echoMode: TextInput.Password
                                                    color: Colors.textPrimary
                                                    font.pixelSize: Typography.body

                                                    background: Rectangle {
                                                        radius: Radius.small
                                                        color: Colors.background
                                                        border.color: Colors.line
                                                    }
                                                }

                                                Item { width: 1; height: 4 }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: "Role"
                                                    color: Colors.textMuted
                                                    font.pixelSize: Typography.caption
                                                }

                                                ComboBox {
                                                    id: roleCombo
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 48

                                                    model: [
                                                        "Nurse", "Doctor",
                                                        "Service", "Admin"
                                                    ]
                                                    currentIndex: model.indexOf(root.formRole)
                                                    onCurrentTextChanged: root.formRole = currentText
                                                    font.pixelSize: Typography.body

                                                    background: Rectangle {
                                                        radius: Radius.small
                                                        color: Colors.background
                                                        border.color: Colors.line
                                                    }

                                                    contentItem: Text {
                                                        leftPadding: 14
                                                        text: roleCombo.displayText
                                                        color: Colors.textPrimary
                                                        font.pixelSize: Typography.body
                                                        verticalAlignment: Text.AlignVCenter
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Row {
                                    spacing: 16

                                    PrimaryButton {
                                        width: 200
                                        height: 48
                                        text: "Create User"
                                        buttonColor: Colors.success
                                        onClicked: {
                                            var ok = root.userControllerData.createUser(root.formUsername, root.formPin, root.formRole, root.formFullName)
                                            if (ok) {
                                                root.formMessage = "User '" + root.formUsername + "' created successfully."
                                                root.formIsError = false
                                                root.clearForm()
                                            } else {
                                                root.formMessage = "Failed. Username must be " + "unique (3+ chars), " + "PIN must be 4 digits."
                                                root.formIsError = true
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: root.formMessage
                                        color: root.formIsError ? Colors.critical : Colors.successBright
                                        font.pixelSize: Typography.body
                                        visible: root.formMessage.length > 0
                                    }
                                }
                            }
                        }

                        // --- Registered Users Table ---
                        Panel {
                            width: parent.width
                            implicitHeight: userListCol.height + 48

                            Column {
                                id: userListCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 24
                                spacing: 8

                                Text {
                                    text: "Registered Users"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.subtitle
                                    font.weight: Font.DemiBold
                                }

                                // Header
                                Row {
                                    width: parent.width
                                    height: 40
                                    Text {
                                        width: parent.width * 0.15
                                        text: "Username"
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.label
                                        font.weight: Font.DemiBold
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Text {
                                        width: parent.width * 0.25
                                        text: "Full Name"
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.label
                                        font.weight: Font.DemiBold
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Text {
                                        width: parent.width * 0.10
                                        text: "Role"
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.label
                                        font.weight: Font.DemiBold
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Text {
                                        width: parent.width * 0.20
                                        text: "Created"
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.label
                                        font.weight: Font.DemiBold
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Text {
                                        width: parent.width * 0.30
                                        text: "Actions"
                                        color: Colors.textSecondary
                                        font.pixelSize: Typography.label
                                        font.weight: Font.DemiBold
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Rectangle {
                                    width: parent.width; height: 1
                                    color: Colors.line
                                }

                                Repeater {
                                    model: root.userControllerData
                                           ? root.userControllerData.listUsers() : []

                                    Rectangle {
                                        id: userRow
                                        required property var modelData
                                        width: parent.width
                                        height: 56
                                        radius: Radius.small
                                        color: Colors.surfaceRaised

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 10

                                            Text {
                                                width: parent.width * 0.15
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: userRow.modelData.username
                                                color: Colors.textPrimary
                                                font.pixelSize: Typography.body
                                                font.family: Typography.monoFamily
                                            }
                                            Text {
                                                width: parent.width * 0.25
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: userRow.modelData.fullName
                                                color: Colors.textPrimary
                                                font.pixelSize: Typography.body
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                width: parent.width * 0.10
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: userRow.modelData.role
                                                color: userRow.modelData.role === "Admin"
                                                       ? Colors.warning : Colors.textPrimary
                                                font.pixelSize: Typography.body
                                                font.weight: Font.DemiBold
                                            }
                                            Text {
                                                width: parent.width * 0.20
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: userRow.modelData.createdAt
                                                color: Colors.textMuted
                                                font.pixelSize: Typography.caption
                                                font.family: Typography.monoFamily
                                            }

                                            Row {
                                                width: parent.width * 0.30
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 10
                                                visible: root.userControllerData
                                                         && root.userControllerData
                                                .currentRole === "Admin"

                                                PrimaryButton {
                                                    width: 120
                                                    height: 38
                                                    text: "Change PIN"
                                                    buttonColor: Colors.accentBlue
                                                    onClicked: {
                                                        root.pwdTargetUser
                                                        = userRow.modelData.username
                                                        root.currentTab = 1
                                                    }
                                                }
                                                PrimaryButton {
                                                    width: 100
                                                    height: 38
                                                    text: "Delete"
                                                    buttonColor: Colors.critical
                                                    visible: userRow.modelData.username
                                                             !== root.userControllerData
                                                    .currentUser
                                                    onClicked: root.userControllerData
                                                    .deleteUser(
                                                        userRow.modelData.username)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // TAB 1: Change PIN
                // =============================================================

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 1

                    contentItem: Column {
                        spacing: 18

                        Text {
                            Layout.fillWidth: true
                            text: "Change PIN"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.title
                            font.weight: Font.DemiBold
                        }

                        Control {
                            width: parent.width
                            padding: 24

                            background: Rectangle {
                                radius: Radius.medium
                                color: Colors.surface
                                border.color: Colors.line
                                border.width: 1
                            }

                            contentItem: Column {
                                id: pwdMainCol
                                spacing: 24

                                RowLayout {
                                    width: parent.width
                                    spacing: 40

                                    // Left: Select User
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            Layout.fillWidth: true
                                            text: "Select User"
                                            color: Colors.textSecondary
                                            font.pixelSize: Typography.label
                                            font.weight: Font.DemiBold
                                        }

                                        ComboBox {
                                            id: pwdUserCombo
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 48
                                            model: {
                                                var users = root.userControllerData
                                                ? root.userControllerData.listUsers()
                                                : []
                                                var names = []
                                                for (var i = 0; i < users.length; i++)
                                                names.push(users[i].username)
                                                return names
                                            }
                                            currentIndex: {
                                                var target = root.pwdTargetUser.length > 0
                                                ? root.pwdTargetUser
                                                : (root.userControllerData
                                                   ? root.userControllerData
                                                     .currentUser : "")
                                                var idx = model
                                                ? model.indexOf(target) : -1
                                                return idx >= 0 ? idx : 0
                                            }
                                            enabled: root.userControllerData
                                                     && root.userControllerData
                                            .currentRole === "Admin"
                                            onCurrentTextChanged:
                                            root.pwdTargetUser = currentText
                                            font.pixelSize: Typography.body
                                            background: Rectangle {
                                                radius: Radius.small
                                                color: Colors.background
                                                border.color: Colors.line
                                            }
                                            contentItem: Text {
                                                leftPadding: 14
                                                text: pwdUserCombo.displayText
                                                color: Colors.textPrimary
                                                font.pixelSize: Typography.body
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }

                                        Text {
                                            visible: root.userControllerData && root.userControllerData.currentRole !== "Admin"
                                            Layout.fillWidth: true
                                            text: "Non-admin users can only " + "change their own PIN."
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                            wrapMode: Text.WordWrap
                                        }
                                    }

                                    // Center: New PIN
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            Layout.fillWidth: true
                                            text: "New PIN"
                                            color: Colors.textSecondary
                                            font.pixelSize: Typography.label
                                            font.weight: Font.DemiBold
                                        }

                                        TextField {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 48
                                            leftPadding: 14
                                            placeholderText: "Enter 4-digit PIN"
                                            text: root.pwdNewPin
                                            onTextChanged: root.pwdNewPin = text
                                            maximumLength: 4
                                            echoMode: TextInput.Password
                                            color: Colors.textPrimary
                                            font.pixelSize: Typography.label
                                            font.family: Typography.monoFamily

                                            background: Rectangle {
                                                radius: Radius.small
                                                color: Colors.background
                                                border.color: Colors.line
                                            }
                                        }
                                    }

                                    // Right: Confirm PIN
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            Layout.fillWidth: true
                                            text: "Confirm PIN"
                                            color: Colors.textSecondary
                                            font.pixelSize: Typography.label
                                            font.weight: Font.DemiBold
                                        }

                                        TextField {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 48
                                            leftPadding: 14
                                            placeholderText: "Re-enter PIN"
                                            text: root.pwdConfirmPin
                                            onTextChanged: root.pwdConfirmPin = text
                                            maximumLength: 4
                                            echoMode: TextInput.Password
                                            color: Colors.textPrimary
                                            font.pixelSize: Typography.label
                                            font.family: Typography.monoFamily

                                            background: Rectangle {
                                                radius: Radius.small
                                                color: Colors.background
                                                border.color: root.pwdConfirmPin.length === 4 && root.pwdConfirmPin !== root.pwdNewPin ? Colors.critical : Colors.line
                                                border.width: root.pwdConfirmPin.length === 4 && root.pwdConfirmPin !== root.pwdNewPin ? 2 : 1
                                            }
                                        }
                                    }
                                }

                                // Action row
                                Row {
                                    width: parent.width
                                    spacing: 20

                                    PrimaryButton {
                                        width: 220
                                        height: 52
                                        text: "Change PIN"
                                        buttonColor: root.pwdNewPin.length === 4 && root.pwdNewPin === root.pwdConfirmPin ? Colors.accentBlue : Colors.disabled

                                        onClicked: {
                                            if (root.pwdNewPin !== root.pwdConfirmPin) {
                                                root.pwdMessage = "PINs do not match."
                                                root.pwdIsError = true
                                                return
                                            }

                                            var target = root.pwdTargetUser.length > 0
                                            ? root.pwdTargetUser
                                            : root.userControllerData.currentUser
                                            var ok = root.userControllerData
                                            .changePin(target, root.pwdNewPin)

                                            if (ok) {
                                                root.pwdMessage = "PIN changed "
                                                + "successfully for '"
                                                + target + "'."
                                                root.pwdIsError = false
                                            } else {
                                                root.pwdMessage = "Failed to change "
                                                + "PIN. Must be 4 digits."
                                                root.pwdIsError = true
                                            }

                                            root.pwdNewPin = ""
                                            root.pwdConfirmPin = ""
                                        }
                                    }

                                    // Status message
                                    Rectangle {
                                        visible: root.pwdMessage.length > 0
                                        width: statusText.width + 32
                                        height: 52
                                        radius: Radius.small
                                        color: root.pwdIsError
                                               ? Colors.criticalBackground
                                               : Colors.successDark
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: statusText
                                            anchors.centerIn: parent
                                            text: root.pwdMessage
                                            color: Colors.textPrimary
                                            font.pixelSize: Typography.body
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // TAB 2: Security
                // =============================================================

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 2

                    contentItem: Column {
                        visible: root.currentTab === 2
                        width: parent.width - 48
                        spacing: 18

                        Text {
                            text: "Security Settings"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.title
                            font.weight: Font.DemiBold
                        }

                        // Full-width session + lock panel
                        Panel {
                            width: parent.width
                            implicitHeight: secCol.height + 48

                            Column {
                                id: secCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 24
                                spacing: 22

                                // Session info row
                                Row {
                                    width: parent.width
                                    spacing: 60

                                    Column {
                                        spacing: 4
                                        Text {
                                            text: "Logged In As"
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                        }
                                        Text {
                                            text: root.userControllerData
                                                  ? root.userControllerData.currentUser
                                                  : "--"
                                            color: Colors.textPrimary
                                            font.pixelSize: Typography.label
                                            font.family: Typography.monoFamily
                                            font.weight: Font.DemiBold
                                        }
                                    }

                                    Column {
                                        spacing: 4
                                        Text {
                                            text: "Role"
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                        }
                                        Text {
                                            text: root.userControllerData
                                                  ? root.userControllerData.currentRole
                                                  : "--"
                                            color: Colors.warning
                                            font.pixelSize: Typography.label
                                            font.weight: Font.DemiBold
                                        }
                                    }

                                    Column {
                                        spacing: 4
                                        Text {
                                            text: "Lock Timeout"
                                            color: Colors.textMuted
                                            font.pixelSize: Typography.caption
                                        }
                                        Text {
                                            text: root.userControllerData
                                                  ? Math.floor(root.userControllerData
                                                               .lockTimeoutSeconds / 60)
                                                    + " min "
                                                    + (root.userControllerData
                                                       .lockTimeoutSeconds % 60)
                                                    + " sec"
                                                  : "--"
                                            color: Colors.textPrimary
                                            font.pixelSize: Typography.label
                                            font.family: Typography.monoFamily
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width; height: 1
                                    color: Colors.line
                                }

                                Text {
                                    text: "Screen Lock Inactivity Timeout"
                                    color: Colors.textSecondary
                                    font.pixelSize: Typography.label
                                    font.weight: Font.DemiBold
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 16

                                    PressureGroupBox {
                                        Layout.preferredWidth: 280
                                        labelText: "Timeout"
                                        value: root.userControllerData
                                               ? root.userControllerData
                                                 .lockTimeoutSeconds : 300
                                        minimumValue: 30
                                        maximumValue: 3600
                                        stepSize: 30
                                        unit: "sec"
                                        onValueChangedByUser: function(v) {
                                            if (root.userControllerData)
                                                root.userControllerData
                                            .setLockTimeoutSeconds(v)
                                        }
                                    }

                                    GridLayout {
                                        Layout.fillWidth: true
                                        columns: 5
                                        rowSpacing: 8
                                        columnSpacing: 10

                                        Repeater {
                                            model: [
                                                { label: "1 min", val: 60 },
                                                { label: "2 min", val: 120 },
                                                { label: "3 min", val: 180 },
                                                { label: "5 min", val: 300 },
                                                { label: "10 min", val: 600 },
                                                { label: "15 min", val: 900 },
                                                { label: "20 min", val: 1200 },
                                                { label: "30 min", val: 1800 },
                                                { label: "45 min", val: 2700 },
                                                { label: "60 min", val: 3600 }
                                            ]
                                            PrefsTabButton {
                                                id: toBtn
                                                required property var modelData
                                                Layout.fillWidth: true
                                                height: 42
                                                text: toBtn.modelData.label
                                                checked: root.userControllerData
                                                         && root.userControllerData
                                                .lockTimeoutSeconds
                                                === toBtn.modelData.val
                                                onClicked: {
                                                    if (root.userControllerData)
                                                    root.userControllerData
                                                    .setLockTimeoutSeconds(
                                                        toBtn.modelData.val)
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width; height: 1
                                    color: Colors.line
                                }

                                PrimaryButton {
                                    width: 220
                                    height: 52
                                    text: "Log Out"
                                    buttonColor: Colors.critical
                                    onClicked: {
                                        if (root.userControllerData)
                                        root.userControllerData.logout()
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // TAB 3: About
                // =============================================================

                Control {
                    Layout.fillWidth: true
                    visible: root.currentTab === 3

                    contentItem: Column {
                        spacing: 18

                        Text {
                            text: "About This Device"
                            color: Colors.textPrimary
                            font.pixelSize: Typography.title
                            font.weight: Font.DemiBold
                        }

                        Panel {
                            width: parent.width
                            implicitHeight: aboutGrid.height + 48

                            GridLayout {
                                id: aboutGrid
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 24
                                columns: 4
                                columnSpacing: 40
                                rowSpacing: 20

                                // Row 1
                                Text {
                                    text: "Manufacturer"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: "Alsons Technology"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: "Model"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: "Smart Ventilator ICU"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.weight: Font.DemiBold
                                }

                                // Row 2
                                Text {
                                    text: "Serial No."
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: "SV-2026-00142"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                }
                                Text {
                                    text: "SW Version"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: root.appSettingsData
                                          ? root.appSettingsData.softwareVersion : "--"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                    font.weight: Font.DemiBold
                                }

                                // Row 3
                                Text {
                                    text: "Qt Version"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: "6.8"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                }
                                Text {
                                    text: "Build Date"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: "2026-06-14"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                }

                                // Row 4
                                Text {
                                    text: "Operating Hours"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: root.appSettingsData
                                          ? root.appSettingsData.operatingHours
                                            .toFixed(1) + " h" : "--"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                }
                                Text {
                                    text: "Database"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: "SQLite Active"
                                    color: Colors.successBright
                                    font.pixelSize: Typography.body
                                    font.weight: Font.DemiBold
                                }

                                // Row 5
                                Text {
                                    text: "Date"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: root.clockData
                                          ? root.clockData.dateText : "--"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                }
                                Text {
                                    text: "Time"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: root.clockData
                                          ? root.clockData.timeText : "--"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                }

                                // Row 6
                                Text {
                                    text: "Timezone"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    Layout.columnSpan: 3
                                    text: root.clockData
                                          ? root.clockData.timeZoneId : "--"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                }

                                // Row 7
                                Text {
                                    text: "Display"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: "1920 x 1080"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.family: Typography.monoFamily
                                }
                                Text {
                                    text: "Logged In"
                                    color: Colors.textMuted
                                    font.pixelSize: Typography.label
                                }
                                Text {
                                    text: root.userControllerData
                                          ? root.userControllerData.currentUser
                                            + " (" + root.userControllerData
                                            .currentRole + ")"
                                          : "--"
                                    color: Colors.textPrimary
                                    font.pixelSize: Typography.body
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}
