import QtQuick
import Quickshell.Io

Rectangle {
    id: toggleRoot
    width: 120
    height: 40
    radius: height / 2

    property color accent: theme.primary

    property bool isActive: false

    color: isActive ? accent : Qt.alpha(theme.surface, 0.4)
    border.color: isActive ? accent : Qt.alpha(theme.surface_variant, 0.4)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Process {
        id: sunsetProc
    }

    MouseArea {
        id: toggleMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {

            if (!toggleRoot.isActive) {
                sunsetProc.command = ["hyprsunset", "-t", "4500"]
                sunsetProc.running = true
            } else {
                sunsetProc.running = false
            }
            toggleRoot.isActive = !toggleRoot.isActive
        }
    }

    Text {
        anchors.centerIn: parent
        text: toggleRoot.isActive? "󰖔  Night Light" : "󰖔  Day Light"

        color: toggleRoot.isActive ? theme.on_primary : theme.on_surface_variant
        font.pixelSize: 13
        font.weight: toggleRoot.isActive ? Font.DemiBold : Font.Normal
        font.letterSpacing: 0.3
    }
}
