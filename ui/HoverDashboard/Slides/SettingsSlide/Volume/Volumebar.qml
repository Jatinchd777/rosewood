import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: settingsAudioRoot
    height: 40
    width: 390

    property color accent: theme.primary

    property var sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: settingsAudioRoot.volume <= 0
    property bool bootGuard: false

    property real visualVolume: dragMouseArea.pressed ? localDragVolume : settingsAudioRoot.volume
    property real localDragVolume: 0.0

    PwObjectTracker {
        id: sinkTracker
        objects: settingsAudioRoot.sink ? [settingsAudioRoot.sink] : []
    }

    Timer {
        id: bootTimer
        interval: 400
        running: true
        repeat: false
        onTriggered: settingsAudioRoot.bootGuard = true
    }

    Rectangle {
        id: track
        anchors.fill: parent
        color: Qt.alpha(theme.surface, 0.4)
        border.color: Qt.alpha(theme.surface_variant, 0.4)
        border.width: 1
        radius: height / 2
        clip: true

        Rectangle {
            id: fillBar
            height: parent.height
            width: parent.width * Math.max(0, Math.min(settingsAudioRoot.visualVolume, 1))
            color: settingsAudioRoot.accent
            radius: parent.radius

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: dragMouseArea
            anchors.fill: parent
            preventStealing: true
            cursorShape: Qt.PointingHandCursor

            function updateVisualVolume(mouse) {
                let pct = Math.max(0.0, Math.min(1.0, mouse.x / width))
                settingsAudioRoot.localDragVolume = pct
            }

            function commitVolumeToSystem() {
                if (!settingsAudioRoot.sink?.audio) return
                settingsAudioRoot.sink.audio.volume = settingsAudioRoot.localDragVolume
            }

            onClicked: (mouse) => {
                updateVisualVolume(mouse)
                commitVolumeToSystem()
            }

            onPositionChanged: (mouse) => updateVisualVolume(mouse)

            onReleased: commitVolumeToSystem()
        }

        Text {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            z: 2

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
            color: settingsAudioRoot.muted ? theme.error : (settingsAudioRoot.visualVolume > 0.10 ? theme.on_primary : theme.on_surface)

            text: settingsAudioRoot.muted ? "󰝟" :
            settingsAudioRoot.visualVolume < 0.33 ? "󰕿" :
            settingsAudioRoot.visualVolume < 0.66 ? "󰖀" : "󰕾"
        }

        Text {
            id: label
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            z: 2

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: settingsAudioRoot.visualVolume > 0.90 ? theme.on_primary : theme.on_surface_variant

            text: settingsAudioRoot.muted ? "muted" : Math.round(settingsAudioRoot.visualVolume * 100) + "%"
        }
    }
}
