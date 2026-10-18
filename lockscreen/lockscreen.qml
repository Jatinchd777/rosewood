import Quickshell
import Quickshell.Wayland
import "./components/"

ShellRoot {
    id: root

    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false
            Qt.quit()
        }
    }

    WlSessionLock {
        id: lock

        locked: true

        WlSessionLockSurface {
            color: "black"

            LockSurface {
                anchors.fill: parent
                context: lockContext
                screenshot: true
            }
        }
    }
}

