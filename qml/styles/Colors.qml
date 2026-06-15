pragma Singleton
// -----------------------------------------------------------------------
// File: Colors.qml
// Description: Application-wide color palette singleton
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick

QtObject {
    property bool nightMode: false

    // -- Background and surface layers --
    readonly property color background: nightMode ? "#100D08" : "#1D2640"
    readonly property color surface: nightMode ? "#1B160E" : "#27324F"
    readonly property color surfaceRaised: nightMode ? "#292012" : "#303B5C"

    // -- Brand and accent --
    readonly property color accentBlue: nightMode ? "#D98B24" : "#4D8EFF"
    readonly property color accentBlueDark: nightMode ? "#8A5416" : "#236AB2"
    readonly property color accentBlueMedium: nightMode ? "#B66E1B" : "#276CB8"
    readonly property color accentCyan: nightMode ? "#C57A22" : "#0B83C9"
    readonly property color progressBlue: nightMode ? "#E39A32" : "#2497FF"
    readonly property color accentBlueSelected: nightMode ? "#7A4712" : "#1D5FAE"
    readonly property color brand: nightMode ? "#D98B24" : "#00A8DF"

    // -- Semantic status --
    readonly property color success: nightMode ? "#C38A35" : "#4CAF50"
    readonly property color successBright: nightMode ? "#E0A54B" : "#18C889"
    readonly property color successDark: nightMode ? "#93611F" : "#0B9D69"
    readonly property color successMuted: nightMode ? "#A66C22" : "#079B66"
    readonly property color warning: nightMode ? "#F0A83B" : "#E8B547"
    readonly property color critical: "#D64545"
    readonly property color criticalBackground: "#7B2A35"
    readonly property color warningBackground: "#65552A"

    // -- Text hierarchy --
    readonly property color textPrimary: nightMode ? "#FFDCA3" : "#FFFFFF"
    readonly property color textSecondary: nightMode ? "#C79B60" : "#AAB2C5"
    readonly property color textMuted: nightMode ? "#A98250" : "#9CA3AE"
    readonly property color textLight: nightMode ? "#D8B47E" : "#C2C5CB"
    readonly property color textValue: nightMode ? "#F0C987" : "#D7D9DC"
    readonly property color textLabel: nightMode ? "#D6AC70" : "#CDCFD5"
    readonly property color textUnit: nightMode ? "#896A43" : "#6C7586"
    readonly property color textSubtle: nightMode ? "#98764A" : "#7C8AA6"

    // -- Interactive element states --
    readonly property color disabled: nightMode ? "#4A3825" : "#59647C"
    readonly property color track: nightMode ? "#6A4E2D" : "#647391"
    readonly property color buttonMuted: nightMode ? "#80613C" : "#8F98A6"
    readonly property color buttonInactive: nightMode ? "#9B7648" : "#A9B0BA"
    readonly property color buttonTest: nightMode ? "#8D6A40" : "#9AA2AE"
    readonly property color border: nightMode ? "#725633" : "#95A1B7"

    // -- Waveform and chart accents --
    readonly property color cyan: nightMode ? "#E1A13C" : "#23C9D8"
    readonly property color magenta: nightMode ? "#D36E32" : "#D96AC5"

    // -- Utility --
    readonly property color line: nightMode ? "#49351F" : "#3A4667"
    readonly property color textBackground: nightMode ? "#5B4126" : "#545B69"
    readonly property color progressTrack: nightMode ? "#3B2C1C" : "#4A5368"
    readonly property color transparent: "#00000000"
}
