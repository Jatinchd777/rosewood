import Quickshell
import QtQml
import QtQuick
import Quickshell.Hyprland

Connections {
    id: root

    signal workspaceChanged()

    target: Hyprland

    function onFocusedWorkspaceChanged() {
        workspaceChanged()
    }
}
