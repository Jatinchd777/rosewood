import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Shared page frame: fixed title/description on top, scrollable content below.
Item {
    id: page

    property var theme
    property string title
    property string description
    default property alias content: contentColumn.data

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 32
        anchors.rightMargin: 24
        anchors.topMargin: 30
        anchors.bottomMargin: 26
        spacing: 4

        Text {
            text: page.title
            color: page.theme.on_background
            font.family: "JetBrains Mono"
            font.pixelSize: 24
            font.weight: Font.Bold
            font.letterSpacing: -0.2
        }

        Text {
            text: page.description
            color: page.theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.bottomMargin: 14
        }

        Flickable {
            id: flick

            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: contentColumn.height + 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded

                contentItem: Rectangle {
                    implicitWidth: 5
                    radius: 3
                    color: Qt.alpha(page.theme.primary, 0.4)
                }

                background: Rectangle {
                    color: "transparent"
                }
            }

            Column {
                id: contentColumn
                width: Math.min(flick.width - 14, 820)
                spacing: 10
            }
        }
    }
}
