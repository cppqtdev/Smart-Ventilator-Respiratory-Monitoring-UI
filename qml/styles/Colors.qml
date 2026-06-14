pragma Singleton
// -----------------------------------------------------------------------
// File: Colors.qml
// Description: Application-wide color palette singleton
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick

QtObject {

    // -- Background and surface layers --
    readonly property color background: "#1D2640"
    readonly property color surface: "#27324F"
    readonly property color surfaceRaised: "#303B5C"

    // -- Brand and accent --
    readonly property color accentBlue: "#4D8EFF"
    readonly property color accentBlueDark: "#236AB2"
    readonly property color accentBlueMedium: "#276CB8"
    readonly property color accentCyan: "#0B83C9"
    readonly property color progressBlue: "#2497FF"
    readonly property color accentBlueSelected: "#1D5FAE"
    readonly property color brand: "#00A8DF"

    // -- Semantic status --
    readonly property color success: "#4CAF50"
    readonly property color successBright: "#18C889"
    readonly property color successDark: "#0B9D69"
    readonly property color successMuted: "#079B66"
    readonly property color warning: "#E8B547"
    readonly property color critical: "#D64545"
    readonly property color criticalBackground: "#7B2A35"
    readonly property color warningBackground: "#65552A"

    // -- Text hierarchy --
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#AAB2C5"
    readonly property color textMuted: "#9CA3AE"
    readonly property color textLight: "#C2C5CB"
    readonly property color textValue: "#D7D9DC"
    readonly property color textLabel: "#CDCFD5"
    readonly property color textUnit: "#6C7586"
    readonly property color textSubtle: "#7C8AA6"

    // -- Interactive element states --
    readonly property color disabled: "#59647C"
    readonly property color track: "#647391"
    readonly property color buttonMuted: "#8F98A6"
    readonly property color buttonInactive: "#A9B0BA"
    readonly property color buttonTest: "#9AA2AE"
    readonly property color border: "#95A1B7"

    // -- Waveform and chart accents --
    readonly property color cyan: "#23C9D8"
    readonly property color magenta: "#D96AC5"

    // -- Utility --
    readonly property color line: "#3A4667"
    readonly property color textBackground: "#545B69"
    readonly property color progressTrack: "#4A5368"
    readonly property color transparent: "#00000000"
}
