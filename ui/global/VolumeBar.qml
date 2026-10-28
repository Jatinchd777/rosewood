import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

Row {
    id: root

    property color accent: theme.primary

    width: parent ? parent.width : 0
    anchors.centerIn: parent

    height: parent ? parent.height : 30
    spacing: 10

    // The default sink is kept alive by AudioManager's PwObjectTracker, so a
    // second tracker here would be redundant.
    property var sink: Pipewire.defaultAudioSink

    property real volume: sink?.audio?.volume ?? 0
    property bool muted: root.volume <= 0
    property bool bootGuard: false

    onVolumeChanged: {
        if (bootGuard && sink && !muted && !trackMouse.pressed)
            soundTimer.restart()
    }

    // Debounce the feedback sound: dragging the slider changes volume many
    // times per second and used to spawn one shell per change.
    Timer {
        id: soundTimer
        interval: 160
        repeat: false
        onTriggered: soundProc.startDetached()
    }

    Timer {
        id: bootTimer
        interval: 400
        running: true
        repeat: false
        onTriggered: root.bootGuard = true
    }

    Process {
        id: soundProc
        command: ["sh", "-c", "$HOME/.config/hypr/scripts/Sounds.sh --volume"]
    }

    Text {
        id: icon

        width: 18
        height: parent.height

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 20

        color: root.muted ? theme.error : theme.on_background

        text:
        root.muted ? "󰝟" :
        root.volume < 0.01 ? "󰕿" :
        root.volume < 0.33 ? "󰕿" :
        root.volume < 0.66 ? "󰖀" :
        "󰕾"
    }

    Rectangle {
        id: track

        width: Math.max(root.width - icon.width - label.width - root.spacing * 2, 0)
        height: 5
        radius: 3

        anchors.verticalCenter: parent.verticalCenter

        color: theme.surface_variant

        Rectangle {
            id: fillBar
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width * Math.max(0, Math.min(root.volume, 1))
            height: parent.height
            radius: parent.radius

            color: root.accent

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: trackMouse
            anchors.fill: parent
            preventStealing: true

            function updateVolume(mouse) {
                if (!root.sink?.audio) return
                let pct = Math.max(0.0, Math.min(1.0, mouse.x / width))
                root.sink.audio.volume = pct
            }

            onClicked: (mouse) => updateVolume(mouse)
            onPositionChanged: (mouse) => updateVolume(mouse)
        }
    }

    Text {
        id: label

        height: parent.height
        font.weight: 600

        verticalAlignment: Text.AlignVCenter

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14

        color: theme.on_background

        text: root.muted
        ? "muted"
        : Math.round(root.volume * 100) + "%"
    }
}
