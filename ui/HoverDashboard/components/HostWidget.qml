import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    Process {
        id: fetchPcName
        command: ["uname", "-n"]
        running: true

        stdout: StdioCollector {
            id: collector
        }
    }

    Column {
        id: column
        spacing: 4

        Text {
            id: hostSignature

            text: collector.text.trim()

            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: 14
            font.bold: true
        }

        Rectangle {
            width: hostSignature.width
            height: 1
            color: root.accent
        }
    }
}
