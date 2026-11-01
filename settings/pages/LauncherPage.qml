import QtQuick
import "../components/"

PageContent {
    id: page

    property var settings

    function columnLabel(value) {
        const count = Math.round(value)
        return count + (count === 1 ? " column" : " columns")
    }

    title: "Launcher"
    description: "Layout of the application launcher."

    SectionTitle {
        theme: page.theme
        text: "GRID"
    }

    SettingSlider {
        theme: page.theme
        title: "Columns"
        description: "Number of application columns in the launcher."
        from: 1
        to: 4
        stepSize: 1
        value: page.settings.launcherColumns
        valueText: page.columnLabel(page.settings.launcherColumns)
        onMoved: (value) => page.settings.launcherColumns = Math.round(value)
    }

    SettingSlider {
        theme: page.theme
        title: "Icon size"
        description: "Application icon size in the launcher grid."
        from: 20
        to: 48
        stepSize: 2
        value: page.settings.launcherIconSize
        suffix: " px"
        onMoved: (value) => page.settings.launcherIconSize = Math.round(value)
    }

    SectionTitle {
        theme: page.theme
        text: "RESULTS"
    }

    SettingSlider {
        theme: page.theme
        title: "Search result limit"
        description: "Maximum matches shown while typing. Browsing without a query still shows every app."
        from: 5
        to: 100
        stepSize: 5
        value: page.settings.launcherMaxResults
        valueText: Math.round(page.settings.launcherMaxResults) + " apps"
        onMoved: (value) => page.settings.launcherMaxResults = Math.round(value)
    }

    SectionTitle {
        theme: page.theme
        text: "TIPS"
    }

    InfoNote {
        theme: page.theme
        icon: "󰃬"
        text: "Start a search with = for the calculator, or : to run a raw bash command."
    }

    InfoNote {
        theme: page.theme
        icon: "󰈊"
        text: "Click an app to launch it, or use the arrow keys and Enter."
    }
}
