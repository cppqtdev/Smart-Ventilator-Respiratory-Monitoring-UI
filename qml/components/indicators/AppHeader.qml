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
