import Quickshell
import QtQuick
import "./components/"

FloatingWindow {
    id: root

    visible: true
    implicitWidth: 1280
    implicitHeight: 720
    color: "black"

    LockContext {
        id: lockContext

        onUnlocked: Qt.quit()

        Shortcut {
            sequence: "Escape"
            onActivated: {
                lockContext.currentText = ""
                lockContext.unlocked()
            }
        }
    }

    LockSurface {
        anchors.fill: parent
        context: lockContext
        screenshot: Quickshell.env("QS_LOCK_BG") !== ""
    }
}

