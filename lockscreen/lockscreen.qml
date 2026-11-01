import Quickshell
import Quickshell.Wayland
import "./components/"
import "./core/Logic/"

ShellRoot {
    id: root

    RosewoodSettings {
        id: lockSettings
    }

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
                settings: lockSettings
                screenshot: true
            }
        }
    }
}

