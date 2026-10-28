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

    InfoNote {
        theme: page.theme
        text: "The bar updates as soon as a value changes, without restarting the shell."
    }
}
