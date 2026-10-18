import QtQuick
import Quickshell.Services.UPower

Row {
    id: root

    spacing: 6

    property color accent: theme.primary
    property color dangerAccent: theme.error
    property color warningAccent: theme.tertiary
    property color mutedAccent: theme.on_surface_variant

    readonly property var battery: UPower.displayDevice

    readonly property bool available: battery !== null

    readonly property int percentage: available
    ? Math.max(0, Math.min(100, Math.round(battery.percentage * 100)))
    : 0

    readonly property bool charging:
    available && battery.state === 1

    readonly property color iconColor: {
        if (!available)
        return mutedAccent

        if (charging)
        return accent

        if (percentage <= 15)
        return dangerAccent

        if (percentage <= 30)
        return warningAccent

        return accent
    }

    function batteryIcon() {
        if (!available)
        return "󰂃"

        if (charging)
        return "󱐋"

        if (percentage > 90)
        return ""
        if (percentage > 70)
        return ""
        if (percentage > 50)
        return ""
        if (percentage > 30)
        return ""
        return ""
    }

    Text {
        text: root.batteryIcon()

        font.family: "JetBrains Mono Nerd Font Propo"
        font.bold: true
        font.pixelSize: 16

        color: root.iconColor
    }

    Text {
        text: percentage == 100 ? "Full" : available ? percentage + "%" : "--%"

        font.family: "JetBrains Mono"
        font.pixelSize: 13
        font.bold: true

        anchors.verticalCenter: parent.verticalCenter
        color: theme.on_surface_variant
    }
}
