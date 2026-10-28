import QtQuick
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background
    property int iconSize: 14
    property int textSize: 13
    property bool active: true

    property real usedGb: 0

    implicitWidth: ramDisplay.implicitWidth
    implicitHeight: ramDisplay.implicitHeight

    // /proc/meminfo is much cheaper to read than spawning `free | awk`.
    function sample() {
        const text = memFile.text()
        if (!text)
            return

        let totalKb = 0
        let availableKb = 0
        const lines = text.split("\n")

        for (let i = 0; i < lines.length; i++) {
            if (lines[i].startsWith("MemTotal:"))
                totalKb = parseInt(lines[i].replace(/\D+/g, ""))
            else if (lines[i].startsWith("MemAvailable:"))
                availableKb = parseInt(lines[i].replace(/\D+/g, ""))
        }

        if (totalKb > 0 && availableKb > 0)
            root.usedGb = (totalKb - availableKb) / 1048576
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        printErrors: false
        onTextChanged: root.sample()
    }

    Timer {
        interval: 3000
        running: root.active
        repeat: true
        onTriggered: memFile.reload()
    }

    onActiveChanged: {
        if (root.active)
            memFile.reload()
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
            text: root.usedGb.toFixed(1) + "gb"
            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: root.textSize
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
