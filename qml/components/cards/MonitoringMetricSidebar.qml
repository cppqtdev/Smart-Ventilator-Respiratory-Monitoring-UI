import QtQuick

Column {
    id: root

    property var ventilatorData

    spacing: 12
    property real tileHeight: (height - spacing * 6) / 7

    MetricTile {
        width: parent.width
        height: root.tileHeight
        label: "Ppeak"
        value: root.ventilatorData.ppeak
        unit: "cmH2O"
        highValue: root.ventilatorData.alarmHighPressure
        lowValue: root.ventilatorData.alarmLowPressure
        state: root.ventilatorData.ppeak > root.ventilatorData.alarmHighPressure ? "critical" : "normal"
    }
    MetricTile {
        width: parent.width
        height: root.tileHeight
        label: "ExpMinVol"
        value: root.ventilatorData.expMinVol
        unit: "L/min"
        highValue: root.ventilatorData.alarmHighMv
        lowValue: "1.0"
        state: root.ventilatorData.expMinVol > root.ventilatorData.alarmHighMv ? "warning" : "normal"
    }
    MetricTile {
        width: parent.width
        height: root.tileHeight
        label: "VTE"
        value: root.ventilatorData.vte
        unit: "mL"
        highValue: "839"
        lowValue: root.ventilatorData.alarmLowVt
        state: root.ventilatorData.vte < root.ventilatorData.alarmLowVt ? "warning" : "normal"
    }
    MetricTile {
        width: parent.width
        height: root.tileHeight
        label: "Ftotal"
        value: root.ventilatorData.ftotal
        unit: "b/min"
        highValue: "40"
        lowValue: "8"
    }
    MetricTile {
        width: parent.width
        height: root.tileHeight
        label: "RCexp"
        value: root.ventilatorData.rcexp
        unit: "s"
        highValue: "5"
        lowValue: "0"
    }
    MetricTile {
        width: parent.width
        height: root.tileHeight
        label: "PEEP"
        value: root.ventilatorData.peep
        unit: "cmH2O"
    }
    MetricTile {
        width: parent.width
        height: root.tileHeight
        label: "%MinVol target"
        value: root.ventilatorData.minuteVolume
        unit: "%"
        highValue: root.ventilatorData.alarmHighMv * 10
        state: root.ventilatorData.minuteVolume > root.ventilatorData.alarmHighMv * 10 ? "critical" : "normal"
    }
}
