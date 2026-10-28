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
