import QtQuick
import Quickshell.Io

Row {
    id: root

    property color accent: theme.primary

    width: parent ? parent.width : 0
    anchors.centerIn: parent

    height: parent ? parent.height : 30
    spacing: 10

    property real brightness: 0.0
    property bool bootGuard: false

    property real _managerBrightness: brightnessManager.currentBrightness

    on_ManagerBrightnessChanged: {
        root.brightness = _managerBrightness
    }

    onBrightnessChanged: {
        if (bootGuard) {
            if (typeof stateEngine !== "undefined" && stateEngine) {
                stateEngine.showBrightness()
            }
        }
    }

    Timer {
        id: bootTimer
        interval: 400
        running: true
        repeat: false
        onTriggered: root.bootGuard = true
    }

    Text {
        id: icon

        width: 18
        height: parent.height

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16

        color: theme.on_background

        text: root.brightness < 0.33 ? "󰃞" :
        root.brightness < 0.66 ? "󰃟" : "󰃠"
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

            width: parent.width * root.brightness
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
    }

    Text {
        id: label

        height: parent.height
        font.weight: 600

        verticalAlignment: Text.AlignVCenter

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14

        color: theme.on_background

        text: Math.round(root.brightness * 100) + "%"
    }
}
