import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background
    property string location: "Chandigarh"
    property bool active: true

    property string weatherIcon: "󰖐"
    property string weatherTemp: "--°C"
    property double lastFetch: 0

    implicitWidth: weatherDisplay.implicitWidth
    implicitHeight: weatherDisplay.implicitHeight

    function refresh() {
        if (fetchWeather.running)
            return

        root.lastFetch = Date.now()
        fetchWeather.running = true
    }

    Process {
        id: fetchWeather
        running: false

        command: [
            "curl",
            "-s",
            "wttr.in/" + root.location + "?format=%C|%t"
        ]

        stdout: StdioCollector {
            id: weatherCollector

            onStreamFinished: {
                const raw = weatherCollector.text.trim()
                if (!raw || !raw.includes("|"))
                    return

                const parts = raw.split("|")
                const condition = parts[0].trim().toLowerCase()
                const temp = parts[1].trim().replace("+", "")

                let icon = "󰖐"

                if (condition === "sunny" || condition === "clear") {
                    icon = "󰖙"
                }
                else if (condition.includes("heavy rain") || condition.includes("torrential")) {
                    icon = "󰖖"
                }
                else if (condition.includes("patchy rain") || condition.includes("nearby")) {
                    icon = "󰖗"
                }
                else if (condition.includes("partly") || condition.includes("patchy")) {
                    if (condition.includes("rain") || condition.includes("drizzle")) icon = "󰖗"
                    else icon = "󰖕"
                }
                else if (condition.includes("overcast") || condition.includes("cloudy")) {
                    icon = "󰖐"
                }
                else if (condition.includes("thunder") || condition.includes("storm")) {
                    icon = "󰖓"
                }
                else if (condition.includes("rain") || condition.includes("drizzle") || condition.includes("shower")) {
                    icon = "󰖗"
                }
                else if (condition.includes("snow") || condition.includes("blizzard") || condition.includes("sleet")) {
                    icon = "󰖘"
                }
                else if (condition.includes("fog") || condition.includes("mist") || condition.includes("haze")) {
                    icon = "󰖑"
                }

                root.weatherIcon = icon
                root.weatherTemp = temp
            }
        }
    }

    Timer {
        interval: 1800000
        running: root.active
        repeat: true
        onTriggered: root.refresh()
    }

    onActiveChanged: {
        if (root.active && Date.now() - root.lastFetch > 1800000)
            root.refresh()
    }

    Component.onCompleted: {
        if (root.active)
            root.refresh()
    }

    Row {
        id: weatherDisplay
        spacing: 8

        Text {
            text: root.weatherIcon
            color: root.accent
            font.family: "JetBrains Mono Nerd Font Propo"
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.weatherTemp
            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: 13
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
