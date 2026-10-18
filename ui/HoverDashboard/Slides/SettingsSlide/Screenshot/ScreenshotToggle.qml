import QtQuick
import Quickshell.Io

Rectangle {
    id: toggleRoot
    width: 120
    height: 40
    radius: height / 2

    property color accent: theme.primary

    color: Qt.alpha(theme.surface, 0.4)
    border.color: Qt.alpha(theme.surface_variant, 0.4)
    border.width: 1

    Process {
        id: snapProc
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                snapProc.exec(["bash", "-c", "~/.config/hypr/scripts/ScreenShot.sh --now"])
            } else {
                snapProc.exec(["bash", "-c", "~/.config/hypr/scripts/ScreenShot.sh --area"])
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "󰹑  Screenshot"
        color: theme.on_surface_variant
        font.pixelSize: 13
        font.weight: Font.Normal
        font.letterSpacing: 0.3
    }
}
