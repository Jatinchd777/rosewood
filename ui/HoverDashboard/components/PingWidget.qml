import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.primary
    property int iconSize: 14
    property int textSize: 13
    property bool active: true

    implicitWidth: pingDisplay.implicitWidth
    implicitHeight: pingDisplay.implicitHeight

    function refresh() {
        if (!fetchPing.running)
            fetchPing.running = true
    }

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
        running: root.active
        repeat: true
        onTriggered: root.refresh()
    }

    onActiveChanged: {
        if (root.active)
            root.refresh()
    }

    Component.onCompleted: {
        if (root.active)
            root.refresh()
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
