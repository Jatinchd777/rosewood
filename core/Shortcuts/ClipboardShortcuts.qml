import QtQuick

Item {
    id: shortcutsRoot

    property bool active: false
    property var stateEngine

    Shortcut {
        sequence: "Escape"
        enabled: shortcutsRoot.active
        onActivated: {
            if (shortcutsRoot.stateEngine)
                shortcutsRoot.stateEngine.showClock()
        }
    }

    Shortcut {
        enabled: shortcutsRoot.active
        sequence: "Down"
        onActivated: if (clipboardListView.currentIndex < clipboardListView.count - 1) clipboardListView.currentIndex++
    }
    Shortcut {
        enabled: shortcutsRoot.active
        sequence: "J"
        onActivated: if (clipboardListView.currentIndex < clipboardListView.count - 1) clipboardListView.currentIndex++
    }
    Shortcut {
        enabled: shortcutsRoot.active
        sequence: "Up"
        onActivated: if (clipboardListView.currentIndex > 0) clipboardListView.currentIndex--
    }
    Shortcut {
        enabled: shortcutsRoot.active
        sequence: "K"
        onActivated: if (clipboardListView.currentIndex > 0) clipboardListView.currentIndex--
    }
    Shortcut {
        sequences: ["Enter", "Return"]
        enabled: shortcutsRoot.active
        onActivated: {
            copySelectedToSystem(clipboardListView.currentIndex)

            if (shortcutsRoot.stateEngine)
                shortcutsRoot.stateEngine.showClock()
        }
    }
}
