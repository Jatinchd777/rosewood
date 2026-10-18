import Quickshell
import QtQuick
import "../../ui/global/PillState.qml"

Item {
    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: {
            stateEngine.showClock()
        }
    }

    Shortcut {
        enabled: root.visible
        sequence: "Down"
        onActivated: if (clipboardListView.currentIndex < clipboardListView.count - 1) clipboardListView.currentIndex++
    }
    Shortcut {
        enabled: root.visible
        sequence: "J"
        onActivated: if (clipboardListView.currentIndex < clipboardListView.count - 1) clipboardListView.currentIndex++
    }
    Shortcut {
        enabled: root.visible
        sequence: "Up"
        onActivated: if (clipboardListView.currentIndex > 0) clipboardListView.currentIndex--
    }
    Shortcut {
        enabled: root.visible
        sequence: "K"
        onActivated: if (clipboardListView.currentIndex > 0) clipboardListView.currentIndex--
    }
    Shortcut {
        sequences: ["Enter", "Return"]
        enabled: root.visible
        onActivated: {
            copySelectedToSystem(clipboardListView.currentIndex);

            if (typeof stateEngine !== "undefined") {
                stateEngine.showClock();
            } else {
                console.warn("stateEngine is out of scope for Shortcut!");
            }
        }
    }
}
