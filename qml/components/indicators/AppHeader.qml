// -----------------------------------------------------------------------
// File: AppHeader.qml
// Description: Top application header bar with mode, patient info, clock, and alarm status
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import "../cards"
import "../../styles"

Control {
    property var alarmData
    property var clockData
    property bool showAlarm: false
    property string mode: "ASV"
    property string patientCategory: "Adult"
    property var patientData
    property string automationStatus: ""

    id: control
    topPadding: Spacing.screenMargin_10
    padding: Spacing.screenMargin

    contentItem: RowLayout {
        spacing: Spacing.panelGap

        StatusPanel {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            mode: control.mode
            patientCategory: control.patientCategory
        }

        Text {
            visible: control.patientData !== undefined && control.patientData !== null
            text: control.patientData
                ? control.patientData.patientId + "  |  "
                  + control.patientData.bedNumber + "  |  "
                  + control.patientData.physician
                : ""
            color: Colors.textSecondary
            font.pixelSize: Typography.caption
            font.family: Typography.monoFamily
        }

        Rectangle {
            visible: control.automationStatus.length > 0
            radius: Radius.small
            color: Colors.surfaceRaised
            border.color: Colors.line
            implicitWidth: automationText.implicitWidth + 20
            implicitHeight: 34

            Text {
                id: automationText
                anchors.centerIn: parent
                text: control.automationStatus
                color: Colors.warning
                font.pixelSize: Typography.caption
                font.family: Typography.monoFamily
                font.weight: Font.DemiBold
            }
        }

        AlarmBanner {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            visible: control.showAlarm
            headline: control.alarmData ? control.alarmData.headline : ""
            detail: control.alarmData ? control.alarmData.detail : ""
        }

        DateTimeBanner {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            clockData: control.clockData
        }
    }
}
