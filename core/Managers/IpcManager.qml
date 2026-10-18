// modules/IpcManager.qml
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var stateEngine

    property var colorsEngine

    IpcHandler {
        target: "pill"

        function setState(stateName: string): void {
            if (stateEngine) {
                stateEngine.state = stateName
            }
        }
    }

    IpcHandler {
        target: "theme"

        function reload(): void {
            if (colorsEngine) {
                colorsEngine.reload()
            }
        }
    }
}
