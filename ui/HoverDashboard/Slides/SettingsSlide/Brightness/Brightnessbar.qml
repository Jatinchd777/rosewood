import QtQuick
import Quickshell.Io

Item {
    id: sliderRoot
    height: 35
    width: 390

    property color accent: theme.primary
    property real brightnessValue: 0.5

    property real _managerBrightness: brightnessManager.currentBrightness
    on_ManagerBrightnessChanged: sliderRoot.brightnessValue = _managerBrightness

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
            width: parent.width * Math.max(0, Math.min(sliderRoot.brightnessValue, 1))
            color: sliderRoot.accent
            radius: parent.radius

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            cursorShape: Qt.PointingHandCursor

            function updateBrightness(mouse) {
                let pct = Math.max(0.05, Math.min(1.0, mouse.x / width))
                sliderRoot.brightnessValue = pct

                brightnessManager.setBrightness(pct)
            }

            onClicked: (mouse) => updateBrightness(mouse)
            onPositionChanged: (mouse) => updateBrightness(mouse)
        }

        Text {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            z: 2

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
            color: sliderRoot.brightnessValue > 0.10 ? theme.on_primary : theme.on_surface

            text: sliderRoot.brightnessValue < 0.33 ? "󰃟" :
            sliderRoot.brightnessValue < 0.66 ? "󰃠" : "󰃡"
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
            color: sliderRoot.brightnessValue > 0.90 ? theme.on_primary : theme.on_surface_variant

            text: Math.round(sliderRoot.brightnessValue * 100) + "%"
        }
    }
}
