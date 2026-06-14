pragma ComponentBehavior: Bound
// -----------------------------------------------------------------------
// File: SystemDiagnosticsScreen.qml
// Description: System information, self-test results, sensor status, and settings
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
    property var clockData
    property var appSettingsData
    property int currentTab: 0
    property int infoTab: 0
    property int settingsTab: 0

    // Sensor status tracking (simulated for demo)
    property var sensorStatus: ({
        "O2 Cell": true,
        "Flow Sensor": true,
        "Pressure Sensor": true,
        "CO2 Sensor": true,
        "Temperature": true,
        "Humidity": false
    })

    // Test result tracking
    property var testResults: [
        { name: "Tightness", status: "Passed", date: "2026-06-12 18:51" },
        { name: "Flow Sensor", status: "Passed", date: "2026-06-12 18:51" },
        { name: "O2 Cell", status: "Passed", date: "2026-06-12 18:51" },
        { name: "Circuit Test", status: "Ready", date: "Not run" },
        { name: "Leak Test", status: "Ready", date: "Not run" },
        { name: "Safety Valve", status: "Ready", date: "Not run" }
    ]

    padding: 24

    function loadScreen(screen, tabIndex) {
        root.currentTab = tabIndex
        mainLoader.sourceComponent = screen
    }

    background: Rectangle {
        radius: Radius.medium
        color: Colors.surface
        border.color: Colors.line
        border.width: 1
    }

    header: Control {
        padding: 24

        contentItem: RowLayout {
            spacing: 20

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Info"
                checked: root.currentTab === 0
                onClicked: root.loadScreen(infoPage, 0)
            }

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Tests & Calib"
                checked: root.currentTab === 1
                onClicked: root.loadScreen(testsPage, 1)
            }

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Sensors"
                checked: root.currentTab === 2
                onClicked: root.loadScreen(sensorsPage, 2)
            }

            PrefsTabButton {
                Layout.fillWidth: true
                text: "Settings"
                checked: root.currentTab === 3
                onClicked: root.loadScreen(settingsPage, 3)
            }
        }
    }

    contentItem: Loader {
        id: mainLoader
        sourceComponent: infoPage
    }

    // ---------------------------------------------------------------
    // Info Tab
    // ---------------------------------------------------------------
    Component {
        id: infoPage
        Row {
            spacing: 22

            ColumnLayout {
                width: parent.width * 0.28
                spacing: 14

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Device"
                    checked: root.infoTab === 0
                    onClicked: root.infoTab = 0
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Software"
                    checked: root.infoTab === 1
                    onClicked: root.infoTab = 1
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Options"
                    checked: root.infoTab === 2
                    onClicked: root.infoTab = 2
                }
            }

            Rectangle {
                width: parent.width * 0.68
                height: parent.height * 0.78
                radius: Radius.small
                color: Colors.disabled
                clip: true

                Text {
                    anchors.fill: parent
                    anchors.margins: 24
                    text: {
                        if (root.infoTab === 0) {
                            return "Device Information\n\n"
                                + "Manufacturer:\tAlsons Technology\n"
                                + "Model:\t\tSmart Ventilator ICU\n"
                                + "Serial No.:\t\tSV-2026-00142\n"
                                + "Operating Hours:\t"
                                + (root.appSettingsData
                                    ? root.appSettingsData.operatingHours.toFixed(1) + " h"
                                    : "--") + "\n"
                                + "Database:\t\tSQLite Active\n"
                                + "Display:\t\t1920 x 1080"
                        }
                        if (root.infoTab === 1) {
                            return "Software Information\n\n"
                                + "SW Version:\t"
                                + (root.appSettingsData
                                    ? root.appSettingsData.softwareVersion
                                    : "--") + "\n"
                                + "QML Engine:\tQt 6.8\n"
                                + "Build Date:\t2026-06-14\n"
                                + "Checksum:\t\tSHA256-VERIFIED\n"
                                + "Boot Mode:\tNormal\n"
                                + "Last Update:\t2026-06-14"
                        }
                        return "Installed Options\n\n"
                            + "Adult/ped.\t\tNeonatal\n"
                            + "nCPAP\t\tTRC\n"
                            + "DuoPAP/APRV\t\tTrends/Loops\n"
                            + "NIV/NIV-ST\t\tP/V Tool Pro\n"
                            + "Masimo Rainbow\t\t---\n"
                            + "Hi Flow O2\t\t---"
                    }
                    color: Colors.textPrimary
                    font.family: Typography.monoFamily
                    font.pixelSize: Typography.bodyLarge
                    wrapMode: Text.WordWrap
                    lineHeight: 1.22
                }
            }
        }
    }

    // ---------------------------------------------------------------
    // Tests & Calibration Tab
    // ---------------------------------------------------------------
    Component {
        id: testsPage
        Flickable {
            contentWidth: width
            contentHeight: testColumn.height + 48
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: testColumn
                x: 24
                y: 24
                width: parent.width - 48
                spacing: 18

                Text {
                    text: "Self-Test & Calibration"
                    color: Colors.textPrimary
                    font.pixelSize: Typography.subtitle
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    text: "Run tests before connecting to patient. "
                        + "All mandatory tests must pass before ventilation can start."
                    color: Colors.textSecondary
                    font.pixelSize: Typography.label
                    wrapMode: Text.WordWrap
                }

                Repeater {
                    model: root.testResults
                    Row {
                        id: testRow
                        required property var modelData
                        required property int index
                        width: parent.width
                        height: 56
                        spacing: 18

                        PrimaryButton {
                            width: 230
                            height: parent.height
                            text: "Run " + testRow.modelData.name
                            buttonColor: testRow.modelData.status === "Passed"
                                ? Colors.successDark
                                : Colors.buttonTest
                            onClicked: {
                                var updated = root.testResults.slice()
                                updated[testRow.index] = {
                                    name: testRow.modelData.name,
                                    status: "Passed",
                                    date: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")
                                }
                                root.testResults = updated
                            }
                        }

                        Rectangle {
                            width: 56
                            height: 56
                            radius: Radius.small
                            color: "transparent"
                            border.color: testRow.modelData.status === "Passed"
                                ? Colors.successBright : Colors.line
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: testRow.modelData.status === "Passed"
                                    ? "\u2713" : "\u2022"
                                color: testRow.modelData.status === "Passed"
                                    ? Colors.successBright : Colors.warning
                                font.pixelSize: Typography.subtitleLarge
                                font.weight: Font.DemiBold
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: testRow.modelData.status
                                color: testRow.modelData.status === "Passed"
                                    ? Colors.successBright : Colors.textMuted
                                font.pixelSize: Typography.body
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: testRow.modelData.date
                                color: Colors.textSecondary
                                font.family: Typography.monoFamily
                                font.pixelSize: Typography.label
                            }
                        }
                    }
                }

                Item { width: 1; height: 12 }

                PrimaryButton {
                    width: 280
                    height: 52
                    text: "Run All Tests"
                    buttonColor: Colors.accentBlue
                    onClicked: {
                        var updated = root.testResults.slice()
                        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")
                        for (var i = 0; i < updated.length; i++) {
                            updated[i] = {
                                name: updated[i].name,
                                status: "Passed",
                                date: now
                            }
                        }
                        root.testResults = updated
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------
    // Sensors Tab
    // ---------------------------------------------------------------
    Component {
        id: sensorsPage

        Flickable {
            contentWidth: width
            contentHeight: sensorColumn.height + 48
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: sensorColumn
                x: 24
                y: 24
                width: parent.width - 48
                spacing: 18

                Text {
                    text: "Sensor Status"
                    color: Colors.textPrimary
                    font.pixelSize: Typography.subtitle
                    font.weight: Font.DemiBold
                }

                Repeater {
                    model: Object.keys(root.sensorStatus)

                    Row {
                        id: sensorRow
                        required property string modelData
                        width: parent.width
                        height: 56
                        spacing: 18

                        PrimaryButton {
                            width: 230
                            height: parent.height
                            text: sensorRow.modelData
                            buttonColor: root.sensorStatus[sensorRow.modelData]
                                ? Colors.successDark : Colors.critical
                        }

                        Rectangle {
                            width: 56
                            height: 56
                            radius: Radius.small
                            color: "transparent"
                            border.color: root.sensorStatus[sensorRow.modelData]
                                ? Colors.successBright : Colors.critical
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: root.sensorStatus[sensorRow.modelData]
                                    ? "\u2713" : "\u2717"
                                color: root.sensorStatus[sensorRow.modelData]
                                    ? Colors.successBright : Colors.critical
                                font.pixelSize: Typography.subtitleLarge
                                font.weight: Font.DemiBold
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.sensorStatus[sensorRow.modelData]
                                ? "Online" : "Offline"
                            color: root.sensorStatus[sensorRow.modelData]
                                ? Colors.successBright : Colors.critical
                            font.pixelSize: Typography.body
                            font.weight: Font.DemiBold
                        }

                        Item { Layout.fillWidth: true }

                        PrimaryButton {
                            width: 140
                            height: parent.height
                            text: root.sensorStatus[sensorRow.modelData]
                                ? "Disable" : "Enable"
                            buttonColor: Colors.surfaceRaised
                            onClicked: {
                                var updated = Object.assign({}, root.sensorStatus)
                                updated[sensorRow.modelData] = !updated[sensorRow.modelData]
                                root.sensorStatus = updated
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------
    // Settings Tab
    // ---------------------------------------------------------------
    Component {
        id: settingsPage
        Row {
            spacing: 20

            ColumnLayout {
                width: parent.width * 0.28
                spacing: 14

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Loudness"
                    checked: root.settingsTab === 0
                    onClicked: root.settingsTab = 0
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Display"
                    checked: root.settingsTab === 1
                    onClicked: root.settingsTab = 1
                }

                PrefsTabButton {
                    Layout.fillWidth: true
                    text: "Date & Time"
                    checked: root.settingsTab === 2
                    onClicked: root.settingsTab = 2
                }
            }

            Rectangle {
                width: parent.width * 0.58
                height: parent.height * 0.84
                radius: Radius.small
                color: Colors.background
                clip: true

                // Loudness settings
                Column {
                    visible: root.settingsTab === 0
                    anchors.centerIn: parent
                    width: parent.width * 0.68
                    spacing: 20

                    PressureGroupBox {
                        anchors.horizontalCenter: parent.horizontalCenter
                        labelText: "Audio Volume"
                        value: root.appSettingsData
                            ? root.appSettingsData.audioVolume : 50
                        unit: "%"
                        onValueChangedByUser: function(v) {
                            if (root.appSettingsData)
                                root.appSettingsData.audioVolume = v
                        }
                    }

                    RowLayout {
                        width: parent.width
                        spacing: 10

                        PrefsTabButton {
                            Layout.fillWidth: true
                            checked: root.appSettingsData.dayNightMode === "Day"
                            text: "Day"
                            onClicked: root.appSettingsData.dayNightMode = "Day"
                        }

                        PrefsTabButton {
                            Layout.fillWidth: true
                            checked: root.appSettingsData.dayNightMode === "Night"
                            text: "Night"
                            onClicked: root.appSettingsData.dayNightMode = "Night"
                        }

                        PrefsTabButton {
                            Layout.fillWidth: true
                            checked: root.appSettingsData.dayNightMode === "Automatic"
                            text: "Automatic"
                            onClicked: root.appSettingsData.dayNightMode = "Automatic"
                        }
                    }

                    Text {
                        width: parent.width
                        text: "Mode: " + root.appSettingsData.dayNightMode
                        color: Colors.textSecondary
                        font.pixelSize: Typography.body
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Display / Brightness settings
                Column {
                    visible: root.settingsTab === 1
                    anchors.centerIn: parent
                    width: parent.width * 0.68
                    spacing: 20

                    PressureGroupBox {
                        anchors.horizontalCenter: parent.horizontalCenter
                        labelText: "Brightness"
                        value: root.appSettingsData
                            ? root.appSettingsData.brightness : 80
                        unit: "%"
                        onValueChangedByUser: function(v) {
                            if (root.appSettingsData)
                                root.appSettingsData.brightness = v
                        }
                    }

                    Text {
                        width: parent.width
                        text: "Language: "
                            + (root.appSettingsData
                                ? root.appSettingsData.language
                                : "--")
                        color: Colors.textPrimary
                        font.family: Typography.monoFamily
                        font.pixelSize: Typography.bodyLarge
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Date & Time settings
                Flickable {
                    visible: root.settingsTab === 2
                    anchors.fill: parent
                    contentWidth: width
                    contentHeight: dateTimeCol.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    Column {
                        id: dateTimeCol
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.86
                        topPadding: 24
                        spacing: 18

                        Text {
                            width: parent.width
                            text: "Date: "
                                + (root.clockData
                                    ? root.clockData.dateText : "--")
                            color: Colors.textPrimary
                            font.family: Typography.monoFamily
                            font.pixelSize: Typography.bodyLarge
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            width: parent.width
                            text: "Time: "
                                + (root.clockData
                                    ? root.clockData.timeText : "--")
                            color: Colors.textPrimary
                            font.family: Typography.monoFamily
                            font.pixelSize: Typography.bodyLarge
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            width: parent.width
                            text: "Timezone: "
                                + (root.clockData
                                    ? root.clockData.timeZoneId : "--")
                            color: Colors.textSecondary
                            font.family: Typography.monoFamily
                            font.pixelSize: Typography.body
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            width: parent.width
                            text: "Select Timezone"
                            color: Colors.textMuted
                            font.pixelSize: Typography.label
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Grid {
                            anchors.horizontalCenter: parent.horizontalCenter
                            columns: 3
                            spacing: 10

                            Repeater {
                                model: root.clockData
                                    ? root.clockData.availableTimeZones()
                                    : []

                                PrimaryButton {
                                    id: tzButton
                                    required property string modelData
                                    width: 150
                                    height: 40
                                    text: {
                                        var parts = tzButton.modelData.split("/")
                                        return parts[parts.length - 1]
                                            .replace("_", " ")
                                    }
                                    buttonColor: root.clockData
                                        && root.clockData.timeZoneId
                                            === tzButton.modelData
                                        ? Colors.accentBlue
                                        : Colors.surfaceRaised
                                    onClicked: {
                                        if (root.clockData)
                                            root.clockData.setTimeZoneId(
                                                tzButton.modelData)
                                        if (root.appSettingsData)
                                            root.appSettingsData.timeZoneId =
                                                tzButton.modelData
                                    }
                                }
                            }
                        }

                        Item { width: 1; height: 12 }
                    }
                }
            }
        }
    }
}
