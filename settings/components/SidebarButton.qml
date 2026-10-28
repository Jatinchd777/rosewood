import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var theme
    property string icon
    property string label
    property bool active

    signal clicked()

    height: 38
    implicitWidth: 200

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.active
            ? Qt.alpha(root.theme.primary, 0.16)
            : (hover.hovered ? Qt.alpha(root.theme.surface, 0.4) : "transparent")
        border.width: 1
        border.color: root.active
            ? Qt.alpha(root.theme.primary, 0.3)
            : "transparent"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }

        Rectangle {
            width: 3
            height: 16
            radius: 2
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            color: root.theme.primary
            opacity: root.active ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 120 }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 12
            spacing: 10

            Text {
                text: root.icon
                color: root.active ? root.theme.primary : root.theme.on_surface_variant
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 16
            }

            Text {
                Layout.fillWidth: true
                text: root.label
                color: root.active ? root.theme.on_background : root.theme.on_surface_variant
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.weight: root.active ? Font.DemiBold : Font.Normal
                elide: Text.ElideRight
            }
        }
    }

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
