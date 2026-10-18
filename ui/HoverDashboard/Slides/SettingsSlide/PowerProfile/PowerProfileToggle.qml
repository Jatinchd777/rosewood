import QtQuick
import Quickshell.Io

Rectangle {
    id: toggleRoot
    width: 120
    height: 40
    radius: height / 2

    property color accent1: theme.secondary
    property color accent2: theme.primary
    property color accent3: theme.tertiary

    property int profileState: 0

    color: profileState === 0 ? accent2 :
    profileState === 1 ? accent3 : accent1

    border.color: color
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }

    Process {
        id: powerProc
    }

    MouseArea {
        id: toggleMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            toggleRoot.profileState = (toggleRoot.profileState + 1) % 3

            if (toggleRoot.profileState === 0) {
                powerProc.exec(["powerprofilesctl", "set", "balanced"]) //
            } else if (toggleRoot.profileState === 1) {
                powerProc.exec(["powerprofilesctl", "set", "performance"]) //
            } else if (toggleRoot.profileState === 2) {
                powerProc.exec(["powerprofilesctl", "set", "power-saver"]) //
            }
        }
    }

    Text {
        anchors.centerIn: parent

        text: toggleRoot.profileState === 0 ? "󰗑  Balanced" :
        toggleRoot.profileState === 1 ? "󰓅  Turbo" : "󰌢  Saver"

        color: theme.on_primary
        font.pixelSize: 13
        font.weight: Font.DemiBold
        font.letterSpacing: 0.3
    }
}
