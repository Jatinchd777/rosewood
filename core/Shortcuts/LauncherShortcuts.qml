import QtQuick

Item {
    id: shortcutsRoot

    property var stateEngine

    readonly property bool launcherOpen: stateEngine ? stateEngine.state === "appLauncher" : false

    Shortcut {
        sequence: "Escape"
        enabled: shortcutsRoot.launcherOpen
        onActivated: {
            if (searchInput.text.length > 0) {
                searchInput.clear()
            } else if (shortcutsRoot.stateEngine) {
                shortcutsRoot.stateEngine.showClock()
            }
        }
    }

    Shortcut {
        sequence: "/"
        enabled: shortcutsRoot.launcherOpen && searchInput.activeFocus === false
        onActivated: searchInput.forceActiveFocus()
    }
    Shortcut {
        sequences: ["Return", "Enter"]
        enabled: shortcutsRoot.launcherOpen && appsGrid.count > 0 && appsGrid.currentIndex >= 0
        onActivated: {
            const currentApp = appsModel.get(appsGrid.currentIndex);
            if (currentApp && currentApp.execCmd)
                appRunner.launch(currentApp.execCmd)

            if (shortcutsRoot.stateEngine)
                shortcutsRoot.stateEngine.showClock()
        }
    }

    Shortcut {
        sequence: "Left"
        enabled: shortcutsRoot.launcherOpen
        onActivated: {
            if (appsGrid.currentIndex > 0) appsGrid.currentIndex -= 1;
        }
    }
    Shortcut {
        sequence: "Right"
        enabled: shortcutsRoot.launcherOpen
        onActivated: {
            if (appsGrid.currentIndex < appsGrid.count - 1) appsGrid.currentIndex += 1;
        }
    }
    Shortcut {
        sequence: "Up"
        enabled: shortcutsRoot.launcherOpen
        onActivated: {
            if (appsGrid.currentIndex >= 2) appsGrid.currentIndex -= 2;
        }
    }
    Shortcut {
        sequence: "Down"
        enabled: shortcutsRoot.launcherOpen
        onActivated: {
            if (appsGrid.currentIndex + 2 < appsGrid.count) appsGrid.currentIndex += 2;
        }
    }

    Shortcut { sequence: "h"; enabled: shortcutsRoot.launcherOpen && searchInput.activeFocus === false; onActivated: if (appsGrid.currentIndex > 0) appsGrid.currentIndex -= 1 }
    Shortcut { sequence: "l"; enabled: shortcutsRoot.launcherOpen && searchInput.activeFocus === false; onActivated: if (appsGrid.currentIndex < appsGrid.count - 1) appsGrid.currentIndex += 1 }
    Shortcut { sequence: "k"; enabled: shortcutsRoot.launcherOpen && searchInput.activeFocus === false; onActivated: if (appsGrid.currentIndex >= 2) appsGrid.currentIndex -= 2 }
    Shortcut { sequence: "j"; enabled: shortcutsRoot.launcherOpen && searchInput.activeFocus === false; onActivated: if (appsGrid.currentIndex + 2 < appsGrid.count) appsGrid.currentIndex += 2 }
}
