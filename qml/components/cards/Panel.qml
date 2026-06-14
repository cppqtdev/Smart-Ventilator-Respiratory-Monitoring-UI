// -----------------------------------------------------------------------
// File: Panel.qml
// Description: Generic styled container with rounded border
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import "../../styles"

Rectangle {
    radius: Radius.medium
    color: Colors.surface
    border.color: Colors.line
    border.width: 1
}
