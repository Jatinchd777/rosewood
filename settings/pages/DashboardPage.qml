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

    SettingToggle {
        theme: page.theme
        title: "Show date"
        description: "Show the date under the clock in the hover dashboard."
        checked: page.settings.showDate
        onToggled: (checked) => page.settings.showDate = checked
    }

    SettingChoice {
        theme: page.theme
        title: "Date style"
        description: "How the date under the dashboard clock is written."
        visible: page.settings.showDate
        options: ["Long", "Short", "ISO"]
        values: ["long", "short", "iso"]
        currentValue: page.settings.dateFormat
        onSelected: (value) => page.settings.dateFormat = value
    }

    SectionTitle {
        theme: page.theme
        text: "WEATHER"
    }

    SettingToggle {
        theme: page.theme
        title: "Show weather"
        description: "Display current conditions on the dashboard clock tab."
        checked: page.settings.showWeather
        onToggled: (checked) => page.settings.showWeather = checked
    }

    SettingText {
        theme: page.theme
        title: "Location"
        description: "City name passed to wttr.in."
        visible: page.settings.showWeather
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
        visible: page.settings.showWeather
        options: ["Metric", "Imperial"]
        values: ["metric", "imperial"]
        currentValue: page.settings.weatherUnit
        onSelected: (value) => page.settings.weatherUnit = value
    }

    SettingSlider {
        theme: page.theme
        title: "Refresh interval"
        description: "How often to fetch the weather from wttr.in."
        visible: page.settings.showWeather
        from: 5
        to: 120
        stepSize: 5
        value: page.settings.weatherRefresh
        suffix: " min"
        onMoved: (value) => page.settings.weatherRefresh = Math.round(value)
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
