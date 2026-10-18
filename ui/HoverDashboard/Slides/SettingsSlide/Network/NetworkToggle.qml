import QtQuick
import Quickshell.Networking

Rectangle {
    id: toggleRoot
    width: 120
    height: 40
    radius: height / 2

    signal requestSubView(string viewName)

    property color accent: theme.primary

    color: Networking.wifiEnabled ? accent : Qt.alpha(theme.surface, 0.4)
    border.color: Networking.wifiEnabled ? accent : Qt.alpha(theme.surface_variant, 0.4)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: toggleMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                toggleRoot.requestSubView("wifi_expanded")
            } else {
                Networking.wifiEnabled = !Networking.wifiEnabled
            }
        }

        onDoubleClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                toggleRoot.requestSubView("wifi_expanded")
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: Networking.wifiEnabled ? "󰤨  Internet" : "󰤭  Offline"
        color: Networking.wifiEnabled ? theme.on_primary : theme.on_surface_variant
        font.pixelSize: 13
        font.weight: Networking.wifiEnabled ? Font.DemiBold : Font.Normal
        font.letterSpacing: 0.3
    }
}
