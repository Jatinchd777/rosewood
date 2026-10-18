import QtQuick
import Quickshell.Bluetooth

Rectangle {
    id: toggleRoot
    width: 120
    height: 40
    radius: height / 2

    signal requestSubView(string viewName)

    property color accent: theme.primary

    property bool isPowered: Bluetooth.defaultAdapter?.enabled ?? false

    color: isPowered ? accent : Qt.alpha(theme.surface, 0.4)
    border.color: isPowered ? accent : Qt.alpha(theme.surface_variant, 0.4)
    border.width: 1
    opacity: 1.0

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: toggleMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                toggleRoot.requestSubView("bt_expanded")
            } else {
                if (Bluetooth.defaultAdapter) {
                    Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                }
            }
        }

        onDoubleClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (Bluetooth.defaultAdapter) {
                    Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                }
                toggleRoot.requestSubView("bt_expanded")
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: isPowered ? "󰂯  Bluetooth" : "󰂲  Disabled"
        color: isPowered ? theme.on_primary : theme.on_surface_variant
        font.pixelSize: 13
        font.weight: isPowered ? Font.DemiBold : Font.Normal
        font.letterSpacing: 0.3
    }
}
