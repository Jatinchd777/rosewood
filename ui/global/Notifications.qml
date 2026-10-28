import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: glanceRoot
    width: parent ? parent.width : 350
    implicitHeight: mainLayout.implicitHeight + 24

    property var stateEngine
    property var manager

    readonly property string activeSummary: manager ? manager.latestSummary : ""
    readonly property string activeBody: manager ? manager.latestBody : ""
    readonly property string activeAppName: manager ? manager.latestAppName : ""
    readonly property int activeUrgency: manager ? manager.latestUrgency : 1
    readonly property var activeNotification: manager ? manager.latest : null

    property color accent: theme.primary

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onEntered: {
            if (glanceRoot.stateEngine) {
                glanceRoot.stateEngine.pauseNotification()
            }
        }

        onExited: {
            if (glanceRoot.stateEngine) {
                glanceRoot.stateEngine.resumeNotification()
            }
        }

        onClicked: {
            if (glanceRoot.manager) {
                glanceRoot.manager.dismissLatest()
            }
            if (glanceRoot.stateEngine) {
                glanceRoot.stateEngine.showClock()
            }
        }
    }

    RowLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 14

        Rectangle {
            width: 4
            Layout.fillHeight: true
            radius: 2
            color: glanceRoot.activeUrgency === 2 ? theme.error : accent
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: glanceRoot.activeSummary
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                    font.bold: true
                    color: theme.on_background
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: glanceRoot.activeAppName.toUpperCase()
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                    color: theme.on_surface_variant
                    font.letterSpacing: 1
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "transparent"
            }

            Text {
                text: glanceRoot.activeBody
                font.family: "JetBrains Mono"
                font.pixelSize: 11
                color: theme.on_surface_variant
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }
}
