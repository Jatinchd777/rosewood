import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../../core/Logic/"
import "../../ui/global/"
import "../../core/Managers/"
import "../../core/Shortcuts/"
import "../global/appLauncher/"

PanelWindow {
    id: root

    ThemeEngine {
        id: theme
    }

    WallustHotReload {
        id: wallustColors
    }

    property var stateEngine
    property bool isFullyLoaded: false
    mask: Region { item: maskTarget }

    implicitWidth: 1200
    implicitHeight: 1200
    exclusiveZone: 26
    color: "transparent"

    ShortcutManager {
        id: shortcut
    }

    anchors { top: true }
    margins { top: 5 }

    Component.onCompleted: {
        isFullyLoaded = true
    }

    readonly property var stateRegistry: {
        "clock":         { w: 115, h: 30,  r: 15, modal: false },
        "volume":        { w: 280, h: 30,  r: 15, modal: false },
        "brightness":    { w: 280, h: 30,  r: 15, modal: false },
        "workspace":     { w: 210, h: 30,  r: 15, modal: false },
        "powermenu":     { w: 400, h: 120, r: 20, modal: true },
        "notifications": { w: 400, h: 80,  r: 20, modal: true },
        "wallpaper":     { w: 1000, h: 500, r: 20, modal: true },
        "clipboard":     { w: 550, h: 400, r: 20, modal: true},
        "appLauncher":   {w: 650, h: 500,  r: 20, modal: true}
    }

    focusable: stateEngine ? stateRegistry[stateEngine.state]?.modal ?? false : false

    function getLayoutValue(state, key) {
        if (pill.state === "hover") {
            if (key === "w") return hoverDashboard.targetWidth
            if (key === "h") return hoverDashboard.targetHeight
            return 20
        }
        if (pill.state === "notifications") {
            if (key === "h") {
                return notifWidget.implicitHeight > 80 ? notifWidget.implicitHeight + 10 : 80
            }
        }

        const cfg = stateRegistry[state] || stateRegistry["clock"]
        return cfg[key]
    }

    WorkspaceManager {
        id: workspace
        onWorkspaceChanged: {
            if (stateEngine) stateEngine.showWorkspace()
        }
    }

    BrightnessManager {
        id: brightnessManager
        stateEngine: root.stateEngine
    }

    ShortcutManager { id: hotkeys; stateEngine: root.stateEngine }
    IpcManager { id: ipcBridge; stateEngine: root.stateEngine; colorsEngine: wallustColors }

    Item {
        id: maskTarget
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: root.getLayoutValue(pill.state, "w")
        height: root.getLayoutValue(pill.state, "h")
    }

    Rectangle {
        id: pill
        //color: Qt.alpha(theme.background, 1)
        color: Qt.alpha(theme.background, 0.65)

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (root.stateEngine) {
                    root.stateEngine.panelHovered = hovered
                }
            }
        }

        property string state: {
            let currentState = stateEngine ? stateEngine.state : "clock";
            let isModal = stateRegistry[currentState]?.modal ?? false;
            return (hover.hovered && !isModal) ? "hover" : currentState;
        }

        width: root.getLayoutValue(state, "w")
        height: root.getLayoutValue(state, "h")
        radius: root.getLayoutValue(state, "r")

        Behavior on width {
            enabled: root.isFullyLoaded
            NumberAnimation {
                duration: 750
                easing.type: Easing.OutQuint
            }
        }

        Behavior on height {
            enabled: root.isFullyLoaded

            NumberAnimation {
                duration: 550
                easing.type: Easing.OutQuint
            }
        }

        Behavior on radius {
            enabled: root.isFullyLoaded

            NumberAnimation {
                duration: 500
                easing.type: Easing.OutQuint
            }
        }

        Behavior on color {
            enabled: root.isFullyLoaded

            ColorAnimation {
                duration: 500
                easing.type: Easing.Linear
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 5

            Clock { visible: pill.state === "clock" }
            Workspace { visible: pill.state === "workspace" }
            VolumeBar { visible: pill.state === "volume" }
            BrightnessBar { visible: pill.state === "brightness" }
            HoverDashboard { id: hoverDashboard; visible: pill.state === "hover"; }
            PowerMenu { visible: pill.state === "powermenu" }
            Notifications { id: notifWidget; visible: pill.state === "notifications"; stateEngine: root.stateEngine; }
            WallpaperPicker { visible: pill.state === "wallpaper" }
            AppLauncher { visible: pill.state === "appLauncher"}
            Clipboard { visible: pill.state === "clipboard" }
        }
    }
}
