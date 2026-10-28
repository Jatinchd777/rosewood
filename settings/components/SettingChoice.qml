pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var theme
    property string title
    property string description
    property var options: []
    property var values: []
    property var currentValue

    signal selected(var value)

    width: parent ? parent.width : 0
    height: layout.implicitHeight + 30
    radius: 10
    color: Qt.alpha(root.theme.surface, 0.4)
    border.width: 1
    border.color: Qt.alpha(root.theme.surface_variant, 0.35)

    RowLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.topMargin: 15
        height: implicitHeight
        spacing: 16

        ColumnLayout {
            Layout.fillWidth: true
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
        }

        Row {
            spacing: 4

            Repeater {
                model: root.options.length

                Rectangle {
                    id: option

                    required property int index

                    readonly property bool isCurrent: root.values[index] === root.currentValue

                    width: optionLabel.implicitWidth + 22
                    height: 28
                    radius: 7
                    color: option.isCurrent
                        ? root.theme.primary
                        : (optionHover.hovered ? Qt.alpha(root.theme.primary, 0.12) : Qt.alpha(root.theme.background, 0.25))
                    border.width: 1
                    border.color: option.isCurrent
                        ? root.theme.primary
                        : (optionHover.hovered ? Qt.alpha(root.theme.primary, 0.35) : Qt.alpha(root.theme.surface_variant, 0.35))

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        id: optionLabel

                        anchors.centerIn: parent
                        text: root.options[option.index]
                        color: option.isCurrent ? root.theme.on_primary : root.theme.on_surface_variant
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                        font.weight: option.isCurrent ? Font.DemiBold : Font.Normal
                    }

                    HoverHandler {
                        id: optionHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selected(root.values[option.index])
                    }
                }
            }
        }
    }
}
