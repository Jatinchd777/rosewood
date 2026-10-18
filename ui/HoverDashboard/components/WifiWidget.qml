import QtQuick
import Quickshell.Networking

Row {
    id: root
    spacing: 6

    property color accent: theme.primary

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null
    readonly property real signal: active ? active.signalStrength : 0

    readonly property string icons: {
        if (!Networking.wifiEnabled) return "󰤮"
        if (!active) return "󰤭"
        let tier = signal > 0.75 ? "󰤨"
        : signal > 0.50 ? "󰤥"
        : signal > 0.25 ? "󰤢"
        : "󰤠"
        return tier
    }
    Text {
        text: root.icons
        font.family: "JetBrains Mono Nerd Font Propo"
        font.pixelSize: 14
        color: accent
    }

    Text {

        text: {
            if (!Networking.wifiEnabled) return "OFF"
            if (!active) return "DISCONNECTED"
            return active.name
        }

        font.family: "JetBrains Mono"
        font.pixelSize: 13
        font.bold: true
        color: theme.on_surface_variant
    }
}
