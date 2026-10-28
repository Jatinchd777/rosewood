import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var theme
    property string title
    property string description
    property bool checked

    signal toggled(bool checked)

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

        Rectangle {
            id: track

            implicitWidth: 42
            implicitHeight: 24
            radius: height / 2
            color: root.checked ? root.theme.primary : Qt.alpha(root.theme.background, 0.35)
            border.width: 1
            border.color: root.checked ? root.theme.primary : Qt.alpha(root.theme.surface_variant, 0.45)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }

            Rectangle {
                width: 18
                height: 18
                radius: 9
                y: 2
                x: root.checked ? track.width - width - 3 : 3
                color: root.checked ? root.theme.on_primary : root.theme.on_surface_variant

                Behavior on x {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggled(!root.checked)
            }
        }
    }
}
