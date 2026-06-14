// -----------------------------------------------------------------------
// File: SplashScreen.qml
// Description: Boot animation with company branding and progress indicator
// Part of: Smart Ventilator and Respiratory Monitoring UI
// -----------------------------------------------------------------------
import QtQuick
import "../styles"

Item {
    id: root
    signal finished()

    property string softwareVersion: "5.6b"
    property real operatingHours: 82.11
    property int progress: 0
    property int stageIndex: 0
    property var bootStages: [
        "Power-on self test",
        "Loading respiratory controller",
        "Checking pressure sensor",
        "Checking flow sensor",
        "Checking oxygen sensor",
        "Initializing alarm priority bus",
        "Preparing patient data cache",
        "Starting ventilator UI"
    ]

    Rectangle {
        anchors.fill: parent
        color: Colors.background
    }

    Timer {
        id: progressTimer
        interval: 55
        repeat: true
        running: true
        onTriggered: {
            var nextProgress = root.progress + (root.progress < 35 ? 2 : root.progress < 78 ? 1 : 3)
            root.progress = Math.min(100, nextProgress)
            root.stageIndex = Math.min(root.bootStages.length - 1, Math.floor(root.progress / 13))
            if (root.progress >= 100) {
                stop()
                finishDelay.start()
            }
        }
    }

    Timer {
        id: finishDelay
        interval: 450
        onTriggered: root.finished()
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -90
        width: Math.min(parent.width * 0.52, 760)
        spacing: 44

        Row {
            width: parent.width
            height: 190
            spacing: 34

            Canvas {
                id: logoMark
                width: 190
                height: 190
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = Colors.brand
                    ctx.lineWidth = 9
                    ctx.lineJoin = "round"
                    ctx.lineCap = "round"

                    ctx.beginPath()
                    ctx.moveTo(58, 148)
                    ctx.lineTo(82, 48)
                    ctx.lineTo(132, 48)
                    ctx.lineTo(132, 84)
                    ctx.moveTo(132, 148)
                    ctx.lineTo(132, 104)
                    ctx.lineTo(170, 104)
                    ctx.lineTo(170, 84)
                    ctx.lineTo(96, 84)
                    ctx.lineTo(82, 148)
                    ctx.lineTo(58, 148)
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.arc(132, 78, 7, 0, Math.PI * 2)
                    ctx.arc(132, 112, 7, 0, Math.PI * 2)
                    ctx.fillStyle = Colors.brand
                    ctx.fill()
                }
            }

            Rectangle {
                width: 4
                height: parent.height * 0.72
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.brand
            }

            Column {
                width: parent.width - logoMark.width - 72
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                    width: parent.width
                    text: "ALSONS"
                    color: Colors.brand
                    font.pixelSize: Math.max(42, Math.min(58, root.width * 0.03))
                    font.weight: Font.DemiBold
                    font.family: Typography.family
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: "TECHNOLOGY"
                    color: Colors.brand
                    font.pixelSize: Math.max(42, Math.min(58, root.width * 0.03))
                    font.weight: Font.DemiBold
                    font.family: Typography.family
                    elide: Text.ElideRight
                }
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.max(80, parent.height * 0.12)
        width: Math.min(parent.width * 0.34, 520)
        spacing: 22

        Rectangle {
            width: parent.width
            height: 18
            radius: height / 2
            color: Colors.progressTrack
            clip: true

            Rectangle {
                width: parent.width * root.progress / 100
                height: parent.height
                radius: parent.radius
                color: Colors.textPrimary

                Behavior on width {
                    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }
            }
        }

        Text {
            width: parent.width
            text: root.bootStages[root.stageIndex] + "  " + root.progress + "%"
            color: Colors.textSecondary
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Typography.body
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: "SW Version: " + root.softwareVersion
            color: Colors.textPrimary
            horizontalAlignment: Text.AlignHCenter
            font.family: Typography.monoFamily
            font.pixelSize: Math.max(30, Math.min(44, root.width * 0.022))
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: "Operating Hours Total: " + root.operatingHours.toFixed(2)
            color: Colors.textPrimary
            horizontalAlignment: Text.AlignHCenter
            font.family: Typography.monoFamily
            font.pixelSize: Math.max(24, Math.min(34, root.width * 0.018))
        }
    }
}
