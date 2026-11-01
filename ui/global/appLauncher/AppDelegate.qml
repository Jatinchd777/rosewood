import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: delegateRoot
    width: Math.floor(launcherRoot.absoluteGridWidth / Math.max(1, launcherRoot.columns))
    height: Math.max(52, launcherRoot.iconSize + 20)

    required property var modelData

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 8
        color: delegateRoot.GridView.isCurrentItem ? colorAccent : "transparent"
        border.color: delegateRoot.GridView.isCurrentItem ? colorAccent : "transparent"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            IconImage {
                id: appIcon
                Layout.preferredWidth: launcherRoot.iconSize
                Layout.preferredHeight: launcherRoot.iconSize

                source: Quickshell.iconPath(
                    delegateRoot.modelData.icon ? delegateRoot.modelData.icon : "application-x-executable",
                    "application-x-executable"
                )

                asynchronous: true
            }

            Text {
                text: delegateRoot.modelData.name
                color: delegateRoot.GridView.isCurrentItem ? theme.on_primary : theme.on_surface
                font.family: "JetBrains Mono"
                font.pixelSize: 13
                font.weight: delegateRoot.GridView.isCurrentItem ? Font.DemiBold : Font.Normal
                Layout.fillWidth: true
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
