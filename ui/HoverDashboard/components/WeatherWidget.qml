import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background
    property string location: "Chandigarh"

    property string weatherIcon: "󰖐"
    property string weatherTemp: "--°C"

    implicitWidth: weatherDisplay.implicitWidth
    implicitHeight: weatherDisplay.implicitHeight

    Process {
        id: fetchWeather
        running: true

        command: [
        "curl",
        "-s",
        "wttr.in/" + root.location + "?format=%C|%t"
        ]

        stdout: StdioCollector {
            id: weatherCollector

            onStreamFinished: {
                let raw = text.trim()
                if (!raw || !raw.includes("|")) return

                let parts = raw.split("|")
                let condition = parts[0].trim().toLowerCase()
                let temp = parts[1].trim().replace("+", "")

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
        running: true
        repeat: true
        triggeredOnStart: false

        onTriggered: {
            fetchWeather.running = false
            fetchWeather.running = true
        }
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
