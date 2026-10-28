import QtQuick

Item {
    id: shortcutsRoot

    property bool active: false
    property var stateEngine

    signal applyRequested(string fileName)

    Shortcut {
        sequence: "Escape"
        enabled: shortcutsRoot.active
        onActivated: {
            if (shortcutsRoot.stateEngine)
                shortcutsRoot.stateEngine.showClock()
        }
    }

    Shortcut {
        sequence: "/"
        enabled: shortcutsRoot.active
        onActivated: searchInput.forceActiveFocus()
    }

    Shortcut {
        sequences: ["Return", "Enter"]
        enabled: shortcutsRoot.active && searchInput.activeFocus === false
        onActivated: {
            if (!grid.currentItem)
                return

            const modelData = wallpaperModel.get(grid.currentIndex)
            if (modelData)
                shortcutsRoot.applyRequested(modelData.fileName)
        }
    }

    Shortcut { sequences: ["Left", "h"]; enabled: shortcutsRoot.active; onActivated: grid.moveCurrentIndexLeft() }
    Shortcut { sequences: ["Right", "l"]; enabled: shortcutsRoot.active; onActivated: grid.moveCurrentIndexRight() }
    Shortcut { sequences: ["Up", "k"]; enabled: shortcutsRoot.active; onActivated: grid.moveCurrentIndexUp() }
    Shortcut { sequences: ["Down", "j"]; enabled: shortcutsRoot.active; onActivated: grid.moveCurrentIndexDown() }
}
