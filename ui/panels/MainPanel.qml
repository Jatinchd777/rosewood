import Quickshell
import QtQuick
import "../../core/Logic/"
import "../../ui/global/"
import "../../core/Managers/"
import "../../core/Shortcuts/"
import "../global/appLauncher/"

PanelWindow {
    id: root

    property var stateEngine
    property var settings
    property bool isFullyLoaded: false

    // The hover dashboard reports its animated size back to the window so the
    // panel can stay small (instead of a 1200x1200 transparent surface).
    property int hoverWidth: 550
    property int hoverHeight: 250
    property bool hoverLoaded: false
    property bool wallpaperLoaded: false
    property bool appLauncherLoaded: false

    ThemeEngine {
        id: theme
    }

    NotificationManager {
        id: notificationMgr
        stateEngine: root.stateEngine
        settings: root.settings
    }

    mask: Region { item: maskTarget }

    implicitWidth: 1010
    implicitHeight: 600
    exclusiveZone: root.settings ? root.settings.exclusiveZone : 26
    color: "transparent"

    anchors { top: true }
    margins { top: root.settings ? root.settings.marginTop : 5 }

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
        "clipboard":     { w: 550, h: 400, r: 20, modal: true },
        "appLauncher":   { w: 650, h: 500, r: 20, modal: true }
    }

    focusable: stateEngine ? stateRegistry[stateEngine.state]?.modal ?? false : false

    function getLayoutValue(state, key) {
        if (pill.state === "hover") {
            if (key === "w") return root.hoverWidth
            if (key === "h") return root.hoverHeight
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

    Connections {
        target: root.stateEngine

        function onStateChanged() {
            if (!root.stateEngine)
                return

            if (root.stateEngine.state === "wallpaper")
                root.wallpaperLoaded = true
            else if (root.stateEngine.state === "appLauncher")
                root.appLauncherLoaded = true
        }
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
    IpcManager { id: ipcBridge; stateEngine: root.stateEngine; colorsEngine: theme }

    Item {
        id: maskTarget
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: root.getLayoutValue(pill.state, "w")
        height: root.getLayoutValue(pill.state, "h")
    }

    Rectangle {
        id: pill
        color: Qt.alpha(theme.background, root.settings ? root.settings.backgroundOpacity : 0.65)

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
            const currentState = stateEngine ? stateEngine.state : "clock"
            const isModal = stateRegistry[currentState]?.modal ?? false
            return (hover.hovered && !isModal) ? "hover" : currentState
        }

        onStateChanged: {
            if (state === "hover")
                root.hoverLoaded = true
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

            Clock { visible: pill.state === "clock"; settings: root.settings }
            Workspace { visible: pill.state === "workspace" }
            VolumeBar { visible: pill.state === "volume" }
            BrightnessBar { visible: pill.state === "brightness" }

            Loader {
                id: hoverLoader
                anchors.fill: parent
                active: root.hoverLoaded
                visible: pill.state === "hover"
                sourceComponent: Component {
                    HoverDashboard {
                        isOpen: pill.state === "hover"
                        notificationManager: notificationMgr
                        settings: root.settings
                        defaultTab: root.settings ? root.settings.defaultDashboardTab : 0
                        onLayoutChanged: (w, h) => {
                            root.hoverWidth = w
                            root.hoverHeight = h
                        }
                    }
                }
            }

            PowerMenu { visible: pill.state === "powermenu" }
            Notifications {
                id: notifWidget
                visible: pill.state === "notifications"
                stateEngine: root.stateEngine
                manager: notificationMgr
            }

            Loader {
                anchors.fill: parent
                active: root.wallpaperLoaded
                visible: pill.state === "wallpaper"
                sourceComponent: Component {
                    WallpaperPicker {
                        stateEngine: root.stateEngine
                        themeEngine: theme
                        settings: root.settings
                    }
                }
            }

            Loader {
                anchors.fill: parent
                active: root.appLauncherLoaded
                visible: pill.state === "appLauncher"
                sourceComponent: Component {
                    AppLauncher {
                        stateEngine: root.stateEngine
                        columns: root.settings ? root.settings.launcherColumns : 2
                        onRequestClose: root.stateEngine.showClock()
                    }
                }

                onLoaded: {
                    if (item && item.prepare)
                        item.prepare()
                }
            }

            Clipboard {
                visible: pill.state === "clipboard"
                stateEngine: root.stateEngine
            }
        }
    }
}
