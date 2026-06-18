import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../../styles"

Control {
    id: root

    property var databaseData
    property var ventilatorData
    readonly property bool active: (databaseData && databaseData.degraded)
                                   || (databaseData && databaseData.readOnly)
                                   || (ventilatorData && !ventilatorData.backendConnected)

    visible: active
    height: active ? 42 : 0

    background: Rectangle {
        color: Colors.warning
        radius: Radius.small
    }

    contentItem: RowLayout {
        spacing: 10

        Text {
            text: "SYSTEM STATUS"
            color: Colors.background
            font.pixelSize: Typography.caption
            font.weight: Font.Bold
        }

        Text {
            Layout.fillWidth: true
            text: {
                var messages = []
                if (root.databaseData && root.databaseData.degraded)
                    messages.push("Storage: " + root.databaseData.storageState)
                if (root.databaseData && root.databaseData.readOnly)
                    messages.push("Filesystem read-only")
                if (root.ventilatorData && !root.ventilatorData.backendConnected)
                    messages.push("Backend: " + root.ventilatorData.backendState)
                return messages.join("  |  ")
            }
            color: Colors.background
            font.pixelSize: Typography.caption
            elide: Text.ElideRight
        }
    }
}
