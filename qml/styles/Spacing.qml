pragma Singleton
// -----------------------------------------------------------------------
// File: Spacing.qml
// Description: Layout spacing and margin singleton
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick

QtObject {
    readonly property int screenMargin_10: 10
    readonly property int screenMargin_8: 8
    readonly property int screenMargin_6: 6
    readonly property int screenMargin_4: 4

    readonly property int screenMargin: 28
    readonly property int panelGap: 20
    readonly property int cardPadding: 22
    readonly property int touch: 64
}
