import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background
    property int iconSize: 14
    property int textSize: 13

    implicitWidth: cpuDisplay.implicitWidth
    implicitHeight: cpuDisplay.implicitHeight

    Process {
        id: fetchCpu

        command: [
            "bash",
            "-c",
            "top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}'"
        ]

        stdout: StdioCollector {
            id: cpuCollector
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            fetchCpu.running = false
            fetchCpu.running = true
        }
    }

    Row {
        id: cpuDisplay
        spacing: 8

        Text {
            text: "󰘚"
            color: root.accent
            font.family: "JetBrains Mono Nerd Font Propo"
            font.pixelSize: root.iconSize

            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: (cpuCollector.text.trim() || "0") + "%"
            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: root.textSize
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
