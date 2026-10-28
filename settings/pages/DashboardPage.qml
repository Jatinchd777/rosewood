import QtQuick
import "../components/"

PageContent {
    id: page

    property var settings

    readonly property var tabNames: ["Clock", "Media", "Controls", "Notifications"]

    title: "Dashboard"
    description: "Clock, weather, and the tab the hover dashboard opens first."

    SectionTitle {
        theme: page.theme
        text: "CLOCK"
    }

    SettingChoice {
        theme: page.theme
        title: "Time format"
        description: "Used by the pill and the dashboard clock."
        options: ["12-hour", "24-hour"]
        values: ["12h", "24h"]
        currentValue: page.settings.clockFormat
        onSelected: (value) => page.settings.clockFormat = value
    }

    SettingToggle {
        theme: page.theme
        title: "Show seconds"
        description: "Show seconds on the hover dashboard clock."
        checked: page.settings.showSeconds
        onToggled: (checked) => page.settings.showSeconds = checked
    }

    SectionTitle {
        theme: page.theme
        text: "WEATHER"
    }

    SettingText {
        theme: page.theme
        title: "Location"
        description: "City name passed to wttr.in."
        value: page.settings.weatherLocation
        placeholder: "Chandigarh"
        onEdited: (text) => {
            if (text.trim().length > 0)
                page.settings.weatherLocation = text
        }
    }

    SettingChoice {
        theme: page.theme
        title: "Units"
        description: "Temperature unit used by the weather widget."
        options: ["Metric", "Imperial"]
        values: ["metric", "imperial"]
        currentValue: page.settings.weatherUnit
        onSelected: (value) => page.settings.weatherUnit = value
    }

    SectionTitle {
        theme: page.theme
        text: "STARTUP"
    }

    SettingSlider {
        theme: page.theme
        title: "Default tab"
        description: "Which dashboard page is selected when it opens."
        from: 0
        to: 3
        stepSize: 1
        value: page.settings.defaultDashboardTab
        valueText: page.tabNames[Math.round(page.settings.defaultDashboardTab)] ?? ""
        onMoved: (value) => page.settings.defaultDashboardTab = Math.round(value)
    }
}
