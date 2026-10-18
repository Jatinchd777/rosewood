import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: delegateRoot
    width: Math.floor(launcherRoot.absoluteGridWidth / 2)
    height: 52

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
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                source: model.icon ? Quickshell.iconPath(model.icon, "application-x-executable") : Quickshell.iconPath("application-x-executable")

                asynchronous: true
            }

            Text {
                text: model.name
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
