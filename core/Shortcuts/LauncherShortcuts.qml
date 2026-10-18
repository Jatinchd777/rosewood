import QtQuick

Item {

    Shortcut {
        sequence: "Escape"
        enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher"
        onActivated: {
            if (searchInput.text.length > 0) {
                searchInput.clear()
            } else {
                stateEngine.showClock()
            }
        }
    }

    Shortcut {
        sequence: "/"
        enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher" && searchInput.activeFocus === false
        onActivated: searchInput.forceActiveFocus()
    }
    Shortcut {
        sequences: ["Return", "Enter"]
        enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher" && appsGrid.count > 0 && appsGrid.currentIndex >= 0
        onActivated: {
            let currentApp = appsModel.get(appsGrid.currentIndex);
            if (currentApp && currentApp.execCmd) {
                appRunner.launch(currentApp.execCmd);
            }
            stateEngine.showClock();
        }
    }

    Shortcut {
        sequence: "Left"
        enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher"
        onActivated: {
            if (appsGrid.currentIndex > 0) appsGrid.currentIndex -= 1;
        }
    }
    Shortcut {
        sequence: "Right"
        enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher"
        onActivated: {
            if (appsGrid.currentIndex < appsGrid.count - 1) appsGrid.currentIndex += 1;
        }
    }
    Shortcut {
        sequence: "Up"
        enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher"
        onActivated: {
            if (appsGrid.currentIndex >= 2) appsGrid.currentIndex -= 2;
        }
    }
    Shortcut {
        sequence: "Down"
        enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher"
        onActivated: {
            if (appsGrid.currentIndex + 2 < appsGrid.count) appsGrid.currentIndex += 2;
        }
    }

    Shortcut { sequence: "h"; enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher" && searchInput.activeFocus === false; onActivated: if (appsGrid.currentIndex > 0) appsGrid.currentIndex -= 1 }
    Shortcut { sequence: "l"; enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher" && searchInput.activeFocus === false; onActivated: if (appsGrid.currentIndex < appsGrid.count - 1) appsGrid.currentIndex += 1 }
    Shortcut { sequence: "k"; enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher" && searchInput.activeFocus === false; onActivated: if (appsGrid.currentIndex >= 2) appsGrid.currentIndex -= 2 }
    Shortcut { sequence: "j"; enabled: typeof stateEngine !== "undefined" && stateEngine.state === "appLauncher" && searchInput.activeFocus === false; onActivated: if (appsGrid.currentIndex + 2 < appsGrid.count) appsGrid.currentIndex += 2 }
}
