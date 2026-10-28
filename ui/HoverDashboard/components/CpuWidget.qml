import QtQuick
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background
    property int iconSize: 14
    property int textSize: 13
    property bool active: true

    property real usage: 0
    property real lastTotal: -1
    property real lastIdle: 0

    implicitWidth: cpuDisplay.implicitWidth
    implicitHeight: cpuDisplay.implicitHeight

    // Parse /proc/stat directly. This replaces `top -bn1` (a shell + awk + top
    // per second) with an in-process read.
    function sample() {
        const text = statFile.text()
        if (!text)
            return

        const line = text.slice(0, text.indexOf("\n"))
        const parts = line.trim().split(/\s+/)
        if (parts.length < 5)
            return

        let total = 0
        for (let i = 1; i < parts.length; i++)
            total += Number(parts[i]) || 0

        const idle = (Number(parts[4]) || 0) + (Number(parts[5]) || 0)

        if (root.lastTotal >= 0) {
            const dTotal = total - root.lastTotal
            const dIdle = idle - root.lastIdle
            if (dTotal > 0)
                root.usage = Math.max(0, Math.min(100, 100 * (dTotal - dIdle) / dTotal))
        }

        root.lastTotal = total
        root.lastIdle = idle
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        printErrors: false
        onTextChanged: root.sample()
    }

    Timer {
        interval: 1000
        running: root.active
        repeat: true
        onTriggered: statFile.reload()
    }

    onActiveChanged: {
        if (root.active) {
            // Re-baseline after being idle so the first sample is meaningful.
            root.lastTotal = -1
            statFile.reload()
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
            text: Math.round(root.usage) + "%"
            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: root.textSize
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
