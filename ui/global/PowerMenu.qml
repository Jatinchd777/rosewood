// widgets/PowerMenu.qml
import QtQuick
import "../../core/Logic/"

Item {
    id: root
    implicitWidth: layout.width
    implicitHeight: layout.height
    anchors.centerIn: parent

    focus: root.visible
    Keys.enabled: root.visible

    property color accent: theme.primary
    property color accent2: theme.primary

    property int currentIndex: 0

    onVisibleChanged: {
        if (visible) {
            root.forceActiveFocus()
            root.currentIndex = 0
        }
    }

    SystemActions { id: sys }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
            root.currentIndex = (root.currentIndex - 1 + 4) % 4
            event.accepted = true
        }
        else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
            root.currentIndex = (root.currentIndex + 1) % 4
            event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            executeAction(root.currentIndex)
            event.accepted = true
        }
    }

    function executeAction(index) {
        if (index === 0) sys.powerOff()
        else if (index === 1) sys.reboot()
        else if (index === 2) sys.suspend()
        else if (index === 3) sys.lock()
    }

    Row {
        id: layout
        spacing: 20
        anchors.centerIn: parent

        MenuButton { index: 0; icon: "󰐥"; label: "POWER";   hoverColor: accent2 }
        MenuButton { index: 1; icon: "󰜉"; label: "REBOOT";  hoverColor: accent2 }
        MenuButton { index: 2; icon: "󰤄"; label: "SUSPEND"; hoverColor: accent2 }
        MenuButton { index: 3; icon: "󰌾"; label: "LOCK";    hoverColor: accent2 }
    }

    component MenuButton: Column {
        id: btn
        required property int index
        required property string icon
        required property string label
        required property color hoverColor

        spacing: 6

        property bool isActive: root.currentIndex === btn.index

        Rectangle {
            id: circle
            width: 46
            height: 46
            radius: 23
            color: btn.isActive ? Qt.alpha(theme.primary_container, 0.66) : "transparent"
            scale: btn.isActive ? 1.1 : 1.0
            anchors.horizontalCenter: parent.horizontalCenter

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

            Text {
                text: btn.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                color: btn.isActive ? btn.hoverColor : root.accent
                anchors.centerIn: parent

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: clickZone
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.executeAction(btn.index)

                onEntered: root.currentIndex = btn.index
            }
        }

        Text {
            text: btn.label
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9
            font.bold: true

            color: btn.isActive ? btn.hoverColor : theme.on_surface_variant
            opacity: btn.isActive ? 1.0 : 0.4

            anchors.horizontalCenter: parent.horizontalCenter

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }
}
