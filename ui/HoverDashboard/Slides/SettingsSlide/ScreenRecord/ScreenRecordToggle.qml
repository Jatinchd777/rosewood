import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: toggleRoot
    width: 120
    height: 40
    radius: height / 2

    property color accent: theme.primary
    property bool isActive: false
    property bool isOpen: true
    property string outputDir: (Quickshell.env("HOME") || "") + "/Videos"

    color: isActive ? theme.error : Qt.alpha(theme.surface, 0.4)
    border.color: isActive ? theme.error : Qt.alpha(theme.surface_variant, 0.4)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Process {
        id: recProc
    }

    Process {
        id: stateProc
        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() === "1") {
                    toggleRoot.isActive = true
                }
            }
        }
    }

    Process {
        id: checkProc
        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() === "0" && toggleRoot.isActive) {
                    toggleRoot.isActive = false
                }
            }
        }
    }

    Timer {
        id: statusPoller
        interval: 3000
        repeat: true
        running: toggleRoot.isActive && toggleRoot.isOpen
        onTriggered: {
            checkProc.exec(["bash", "-c", "~/.config/quickshell/scripts/recorder.sh running"])
        }
    }

    Component.onCompleted: {
        stateProc.exec(["bash", "-c", "~/.config/quickshell/scripts/recorder.sh state"])
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (!toggleRoot.isActive) {
                var filename = "recording_" + new Date().toISOString().replace(/[:.]/g, "-") + ".mp4"
                recProc.exec(["bash", "-c", "~/.config/quickshell/scripts/recorder.sh start " + toggleRoot.outputDir + "/" + filename])
                toggleRoot.isActive = true
            } else {
                recProc.exec(["bash", "-c", "~/.config/quickshell/scripts/recorder.sh stop"])
                toggleRoot.isActive = false
            }
        }
    }

    Rectangle {
        visible: toggleRoot.isActive
        width: 8
        height: 8
        radius: 4
        color: theme.error
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        SequentialAnimation on opacity {
            // Without the running gate this animation keeps the whole shell
            // repainting at 60 fps even when nothing is being recorded.
            running: toggleRoot.isOpen && toggleRoot.isActive
            loops: Animation.Infinite
            NumberAnimation { to: 0.2; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
        }
    }

    Text {
        anchors.centerIn: parent
        text: toggleRoot.isActive ? "󰑋  Rec" : "󰻃  Record"
        color: toggleRoot.isActive ? theme.on_primary : theme.on_surface_variant
        font.pixelSize: 13
        font.weight: toggleRoot.isActive ? Font.DemiBold : Font.Normal
        font.letterSpacing: 0.3
    }
}
