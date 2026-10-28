import QtQuick

Rectangle {
    id: root

    property var theme
    property string text
    property string icon: "󰋽"

    width: parent ? parent.width : implicitWidth
    height: note.implicitHeight + 24
    radius: 10
    color: Qt.alpha(root.theme.surface, 0.34)
    border.width: 1
    border.color: Qt.alpha(root.theme.surface_variant, 0.35)

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        width: 3
        radius: 2
        color: root.theme.primary
    }

    Row {
        id: note

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Text {
            text: root.icon
            color: root.theme.primary
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 14
            anchors.top: parent.top
            anchors.topMargin: 1
        }

        Text {
            width: parent.width - 34
            text: root.text
            color: root.theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: 11
            lineHeight: 1.25
            wrapMode: Text.WordWrap
        }
    }
}
