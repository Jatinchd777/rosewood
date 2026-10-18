// modules/ShortcutManager.qml
import QtQuick
import Quickshell

Item {
    id: root

    property var stateEngine
    property var wallpaperPicker

    Shortcut {
        sequence: "Escape"
        enabled: stateEngine ? stateEngine.state === "powermenu" : false

        onActivated: {
            if (stateEngine) {
                stateEngine.showClock()
            }
        }
    }
}
