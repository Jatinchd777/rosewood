import QtQuick
import Quickshell
import "../components/"

PageContent {
    id: page

    property var settings

    readonly property var monitorNames: {
        const names = Quickshell.screens.map(screen => screen.name)
        if (page.settings.lockMonitor !== "" && names.indexOf(page.settings.lockMonitor) === -1)
            names.push(page.settings.lockMonitor)
        return names
    }

    title: "Lock Screen"
    description: "Screen used to capture the lock screen background."

    SectionTitle {
        theme: page.theme
        text: "DISPLAY"
    }

    SettingChoice {
        theme: page.theme
        title: "Monitor"
        description: "grim captures this output before the lock surface appears."
        options: page.monitorNames
        values: page.monitorNames
        currentValue: page.settings.lockMonitor
        onSelected: (value) => page.settings.lockMonitor = value
    }

    SectionTitle {
        theme: page.theme
        text: "APPEARANCE"
    }

    SettingToggle {
        theme: page.theme
        title: "Use captured desktop"
        description: "Blur a screenshot of the desktop behind the lock screen. Turn off to use the saved wallpaper instead."
        checked: page.settings.lockUseScreenshot
        onToggled: (checked) => page.settings.lockUseScreenshot = checked
    }

    SettingSlider {
        theme: page.theme
        title: "Background blur"
        description: "Blur radius applied to the lock-screen background."
        from: 0
        to: 64
        stepSize: 2
        value: page.settings.lockBlur
        suffix: " px"
        onMoved: (value) => page.settings.lockBlur = Math.round(value)
    }

    SettingSlider {
        theme: page.theme
        title: "Background dim"
        description: "Dark overlay over the lock-screen background."
        from: 0
        to: 0.85
        stepSize: 0.05
        value: page.settings.lockDim
        valueText: Math.round(page.settings.lockDim * 100) + "%"
        onMoved: (value) => page.settings.lockDim = value
    }

    InfoNote {
        theme: page.theme
        icon: "󰍹"
        text: "The screenshot is temporary and removed after the session unlocks."
    }

    InfoNote {
        theme: page.theme
        icon: "󰌾"
        text: "Run ~/.config/quickshell/lockscreen/lock.sh to lock the session."
    }
}
