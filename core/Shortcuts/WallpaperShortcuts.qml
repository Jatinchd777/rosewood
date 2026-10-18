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
        sequence: "/"
        enabled: root.visible
        onActivated: searchInput.forceActiveFocus()
    }

    Shortcut {
        sequence: "Return"
        enabled: root.visible && searchInput.activeFocus === false
        onActivated: {
            if (grid.currentItem) {
                let modelData = wallpaperModel.get(grid.currentIndex)
                let fullPath = "/home/lilarchie/Pictures/wallpapers/" + modelData.fileName
                let applyProc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                applyProc.command = ["/home/lilarchie/.config/quickshell/scripts/ApplyWallpaper.sh", fullPath]
                applyProc.running = true
                themeEngine.refreshTheme()
            }
        }
    }

    Shortcut { sequences: ["Left", "h"]; enabled: root.visible; onActivated: grid.moveCurrentIndexLeft() }
    Shortcut { sequences: ["Right", "l"]; enabled: root.visible; onActivated: grid.moveCurrentIndexRight() }
    Shortcut { sequences: ["Up", "k"]; enabled: root.visible; onActivated: grid.moveCurrentIndexUp() }
    Shortcut { sequences: ["Down", "j"]; enabled: root.visible; onActivated: grid.moveCurrentIndexDown() }
}
