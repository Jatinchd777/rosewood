import QtQuick

Item {
    id: shortcutsRoot

    property var stateEngine
    property var launcher

    readonly property bool launcherOpen: stateEngine ? stateEngine.state === "appLauncher" : false
    readonly property bool appMode: shortcutsRoot.launcher
        ? (!shortcutsRoot.launcher.isCalcMode && !shortcutsRoot.launcher.isCmdMode)
        : false

    Shortcut {
        sequence: "Escape"
        enabled: shortcutsRoot.launcherOpen
        onActivated: {
            if (shortcutsRoot.launcher && shortcutsRoot.launcher.query.length > 0) {
                shortcutsRoot.launcher.clearSearch()
            } else if (shortcutsRoot.stateEngine) {
                shortcutsRoot.stateEngine.showClock()
            }
        }
    }

    Shortcut {
        sequence: "/"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher && !shortcutsRoot.launcher.searchHasFocus
        onActivated: shortcutsRoot.launcher.focusSearch()
    }

    Shortcut {
        sequences: ["Return", "Enter"]
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.appMode
            && shortcutsRoot.launcher.appCount > 0
            && shortcutsRoot.launcher.isCurrentItemValid
        onActivated: shortcutsRoot.launcher.launchCurrent()
    }

    Shortcut {
        sequence: "Left"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher
        onActivated: shortcutsRoot.launcher.selectLeft()
    }
    Shortcut {
        sequence: "Right"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher
        onActivated: shortcutsRoot.launcher.selectRight()
    }
    Shortcut {
        sequence: "Up"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher
        onActivated: shortcutsRoot.launcher.selectUp()
    }
    Shortcut {
        sequence: "Down"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher
        onActivated: shortcutsRoot.launcher.selectDown()
    }

    Shortcut {
        sequence: "h"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher && !shortcutsRoot.launcher.searchHasFocus
        onActivated: shortcutsRoot.launcher.selectLeft()
    }
    Shortcut {
        sequence: "l"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher && !shortcutsRoot.launcher.searchHasFocus
        onActivated: shortcutsRoot.launcher.selectRight()
    }
    Shortcut {
        sequence: "k"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher && !shortcutsRoot.launcher.searchHasFocus
        onActivated: shortcutsRoot.launcher.selectUp()
    }
    Shortcut {
        sequence: "j"
        enabled: shortcutsRoot.launcherOpen && shortcutsRoot.launcher && !shortcutsRoot.launcher.searchHasFocus
        onActivated: shortcutsRoot.launcher.selectDown()
    }
}
