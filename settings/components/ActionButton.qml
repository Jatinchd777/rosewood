import QtQuick

Rectangle {
    id: root

    property var theme
    property string text
    property string icon: ""
    property bool primary: false

    signal clicked()

    implicitWidth: label.implicitWidth + 32
    implicitHeight: 34
    radius: 8
    color: root.primary
        ? (hover.hovered ? Qt.alpha(root.theme.primary, 0.9) : root.theme.primary)
        : (hover.hovered ? Qt.alpha(root.theme.primary, 0.16) : Qt.alpha(root.theme.surface, 0.4))
    border.width: 1
    border.color: root.primary
        ? root.theme.primary
        : (hover.hovered ? Qt.alpha(root.theme.primary, 0.4) : Qt.alpha(root.theme.surface_variant, 0.4))

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 120 }
    }

    Text {
        id: label

        anchors.centerIn: parent
        text: root.icon !== "" ? root.icon + "  " + root.text : root.text
        color: root.primary
            ? root.theme.on_primary
            : (hover.hovered ? root.theme.primary : root.theme.on_surface)
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 11
        font.weight: Font.DemiBold

        Behavior on color {
            ColorAnimation { duration: 120 }
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
