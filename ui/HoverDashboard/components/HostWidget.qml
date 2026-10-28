import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background
    property string hostName: ""

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    // Read the hostname from procfs instead of spawning `uname -n`.
    FileView {
        id: hostFile
        path: "/proc/sys/kernel/hostname"
        printErrors: false
        onTextChanged: root.hostName = hostFile.text().trim()
    }

    Column {
        id: column
        spacing: 4

        Text {
            id: hostSignature

            text: root.hostName

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
