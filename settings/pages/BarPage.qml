import QtQuick
import "../components/"

PageContent {
    id: page

    property var settings

    title: "Bar"
    description: "Position and transparency of the top pill."

    SectionTitle {
        theme: page.theme
        text: "GEOMETRY"
    }

    SettingSlider {
        theme: page.theme
        title: "Top margin"
        description: "Gap between the top screen edge and the pill."
        from: 0
        to: 40
        stepSize: 1
        value: page.settings.marginTop
        suffix: " px"
        onMoved: (value) => page.settings.marginTop = Math.round(value)
    }

    SettingSlider {
        theme: page.theme
        title: "Exclusive zone"
        description: "Space reserved for the bar. Set to 0 to let windows use the full screen."
        from: 0
        to: 80
        stepSize: 1
        value: page.settings.exclusiveZone
        suffix: " px"
        onMoved: (value) => page.settings.exclusiveZone = Math.round(value)
    }

    SettingSlider {
        theme: page.theme
        title: "Workspace dots"
        description: "How many workspace indicators to show in the pill and dashboard."
        from: 1
        to: 10
        stepSize: 1
        value: page.settings.workspaceCount
        valueText: Math.round(page.settings.workspaceCount) + " dots"
        onMoved: (value) => page.settings.workspaceCount = Math.round(value)
    }

    SectionTitle {
        theme: page.theme
        text: "APPEARANCE"
    }

    SettingSlider {
        theme: page.theme
        title: "Background opacity"
        description: "How much of the wallpaper shows through the pill and this settings window."
        from: 0.2
        to: 1
        stepSize: 0.05
        value: page.settings.backgroundOpacity
        valueText: Math.round(page.settings.backgroundOpacity * 100) + "%"
        onMoved: (value) => page.settings.backgroundOpacity = value
    }

    SectionTitle {
        theme: page.theme
        text: "BEHAVIOR"
    }

    SettingSlider {
        theme: page.theme
        title: "Status popup duration"
        description: "How long volume, brightness and workspace changes stay on the pill."
        from: 500
        to: 5000
        stepSize: 100
        value: page.settings.statusDuration
        valueText: (Math.round(page.settings.statusDuration / 100) / 10).toFixed(1) + " s"
        onMoved: (value) => page.settings.statusDuration = Math.round(value)
    }

    InfoNote {
        theme: page.theme
        text: "The bar updates as soon as a value changes, without restarting the shell."
    }
}
