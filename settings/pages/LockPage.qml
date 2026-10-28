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
