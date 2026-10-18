import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background
    property int iconSize: 14
    property int textSize: 13

    implicitWidth: ramDisplay.implicitWidth
    implicitHeight: ramDisplay.implicitHeight

    Process {
        id: fetchRam

        command: [
            "bash",
            "-c",
            "free -b | awk '/Mem:/ {printf \"%.1fgb\", $3/1024/1024/1024}'"
        ]

        stdout: StdioCollector {
            id: ramCollector
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            fetchRam.running = false
            fetchRam.running = true
        }
    }

    Row {
        id: ramDisplay
        spacing: 8

        Text {
            text: "󰍛"
            color: root.accent
            font.family: "JetBrains Mono Nerd Font Propo"
            font.pixelSize: root.iconSize

            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: (ramCollector.text.trim() || "0.0gb")
            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: root.textSize
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
