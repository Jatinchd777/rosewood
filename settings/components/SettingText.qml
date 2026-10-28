import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property var theme
    property string title
    property string description
    property string value
    property string placeholder: ""

    signal edited(string text)

    width: parent ? parent.width : 0
    height: layout.implicitHeight + 30
    radius: 10
    color: Qt.alpha(root.theme.surface, 0.4)
    border.width: 1
    border.color: Qt.alpha(root.theme.surface_variant, 0.35)

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.topMargin: 15
        height: implicitHeight
        spacing: 2

        Text {
            Layout.fillWidth: true
            text: root.title
            color: root.theme.on_background
            font.family: "JetBrains Mono"
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.description
            color: root.theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: 11
            lineHeight: 1.2
            wrapMode: Text.WordWrap
        }

        TextField {
            id: field

            Layout.fillWidth: true
            Layout.topMargin: 6
            text: root.value
            placeholderText: root.placeholder
            placeholderTextColor: Qt.alpha(root.theme.on_surface_variant, 0.5)
            color: root.theme.on_background
            selectionColor: root.theme.primary
            selectedTextColor: root.theme.on_primary
            font.family: "JetBrains Mono"
            font.pixelSize: 12
            leftPadding: 10
            rightPadding: 10
            topPadding: 8
            bottomPadding: 8
            selectByMouse: true

            onTextEdited: root.edited(text)

            background: Rectangle {
                radius: 8
                color: Qt.alpha(root.theme.background, 0.35)
                border.width: 1
                border.color: field.activeFocus
                    ? root.theme.primary
                    : Qt.alpha(root.theme.surface_variant, 0.4)

                Behavior on border.color {
                    ColorAnimation { duration: 120 }
                }
            }
        }
    }
}
