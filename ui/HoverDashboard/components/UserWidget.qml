import QtQuick
import Quickshell

Item {
    id: root

    property color accent: theme.on_background

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    Column {
        id: column
        spacing: 4

        Text {
            id: userSignature
            text: Quickshell.env("USER")

            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: 14
            font.bold: true
        }

        Rectangle {
            width: userSignature.width
            height: 1
            color: root.accent
        }
    }
}
