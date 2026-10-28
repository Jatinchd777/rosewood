import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Row {
    id: workspaceRow
    spacing: 10
    anchors.centerIn: parent

    property color accent: theme.primary
    property color darkAccent: theme.secondary

    // Build the id -> workspace map once per workspace-list change instead of
    // running Array.find() inside ten separate dot bindings.
    readonly property var workspaceMap: {
        const map = {}
        const workspaces = Hyprland.workspaces.values
        for (let i = 0; i < workspaces.length; i++)
            map[workspaces[i].id] = workspaces[i]
        return map
    }

    readonly property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1

    Repeater {
        model: 10
        Rectangle {
            id: dot

            property var wsInstance: workspaceRow.workspaceMap[index + 1]
            property bool isFocused: workspaceRow.focusedId === (index + 1)
            property bool isOccupied: wsInstance !== undefined

            width: isFocused ? 18 : (isOccupied ? 8 : 6)
            height: 6
            radius: 3

            color: isFocused
            ? darkAccent
            : (isOccupied ? accent : theme.primary_container)

            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuint
                }
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: wsInstance?.activate()
            }
        }
    }
}
