import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.primary
    property int iconSize: 14
    property int textSize: 13

    implicitWidth: pingDisplay.implicitWidth
    implicitHeight: pingDisplay.implicitHeight

    Process {
        id: fetchPing

        command: [
            "bash",
            "-c",
            "ping -c1 -W1 1.1.1.1 | awk -F'time=' '/time=/{print int($2) \"ms\"}'"
        ]

        stdout: StdioCollector {
            id: pingCollector
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            fetchPing.running = false
            fetchPing.running = true
        }
    }

    Row {
        id: pingDisplay
        spacing: 8

        Text {
            text: "󰓅"
            color: root.accent
            font.family: "JetBrains Mono Nerd Font Propo"
            font.pixelSize: root.iconSize

            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: pingCollector.text.trim() || "--ms"
            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: root.textSize
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
