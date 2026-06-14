pragma Singleton
// -----------------------------------------------------------------------
// File: Typography.qml
// Description: Font family and size scale singleton
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick

QtObject {
    readonly property string family: "Arial"
    readonly property string monoFamily: "Courier New"

    // Size scale for consistent text sizing across the application.
    // Each tier has a defined purpose; prefer these over arbitrary pixel values.
    readonly property int caption: 14
    readonly property int small: 16
    readonly property int label: 18
    readonly property int body: 20
    readonly property int bodyLarge: 22
    readonly property int subtitle: 24
    readonly property int subtitleLarge: 28
    readonly property int title: 32
    readonly property int titleLarge: 34
    readonly property int headline: 42
    readonly property int value: 56
}
