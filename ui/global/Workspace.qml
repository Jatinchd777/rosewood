import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Row {
    id: workspaceRow
    spacing: 10
    anchors.centerIn: parent

    property color accent: theme.primary
    property color darkAccent: theme.secondary


    Repeater {
        model: 10
        Rectangle {
            id: dot

            property var wsInstance: Hyprland.workspaces.values.find(
                w => w.id === (index + 1)
            )
            property bool isFocused: Hyprland.focusedWorkspace
            && Hyprland.focusedWorkspace.id === (index + 1)
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
