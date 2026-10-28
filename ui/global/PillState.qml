import QtQuick
import Quickshell

Item {
    id: root
    visible: false

    property string state: "clock"
    property bool panelHovered: false

    readonly property var stateRegistry: {
        "clock":        { "modal": false },
        "volume":       { "modal": false },
        "brightness":   { "modal": false },
        "workspace":    { "modal": false },
        "notifications":{ "modal": false },
        "powermenu":    { "modal": true  },
        "wallpaper":    { "modal": true  },
        "clipboard":    { "modal": true  },
        "appLauncher":  { "modal": true  }
    }

    function isHoverOverrideActive() {
        let isModal = stateRegistry[state]?.modal ?? false;
        return root.panelHovered && !isModal;
    }

    function isPersistentState() {
        return state === "wallpaper" ||
        state === "powermenu" ||
        state === "clipboard" ||
        state === "appLauncher"
    }

    function clearTimers() {
        volumeTimer.stop()
        workspaceTimer.stop()
        notificationTimer.stop()
        brightnessTimer.stop()
    }

    function showClock() {
        clearTimers()
        state = "clock"
    }

    function showVolume() {
        if (isPersistentState() || isHoverOverrideActive()) return
        clearTimers()
        state = "volume"
        volumeTimer.start()
    }

    function showBrightness() {
        if (isPersistentState() || isHoverOverrideActive()) return
        clearTimers()
        state = "brightness"
        brightnessTimer.start()
    }

    function showWorkspace() {
        if (isPersistentState() || isHoverOverrideActive()) return
        clearTimers()
        state = "workspace"
        workspaceTimer.start()
    }

    function showAppLauncher() {
        clearTimers()
        state = "appLauncher"
    }

    function showSmallRect() {
        clearTimers()
        state = "powermenu"
    }

    function showWallpaper() {
        clearTimers()
        state = "wallpaper"
    }

    function showClipboard() {
        clearTimers()
        state = "clipboard"
    }

    function showNotifications() {
        if (isPersistentState() || isHoverOverrideActive()) return
        clearTimers()
        state = "notifications"
        notificationTimer.start()
    }

    function pauseNotification() {
        notificationTimer.stop()
    }

    function resumeNotification() {
        if (root.state === "notifications")
            notificationTimer.restart()
    }

    Timer {
        id: volumeTimer
        interval: 1000
        onTriggered: {
            if (root.state !== "volume") return
            if (root.isHoverOverrideActive()) volumeTimer.restart()
            else root.showClock()
        }
    }

    Timer {
        id: workspaceTimer
        interval: 1000
        onTriggered: {
            if (root.state !== "workspace") return
            if (root.isHoverOverrideActive()) workspaceTimer.restart()
            else root.showClock()
        }
    }

    Timer {
        id: notificationTimer
        interval: 3000
        onTriggered: {
            if (root.state !== "notifications") return
            if (root.isHoverOverrideActive()) notificationTimer.restart()
            else root.showClock()
        }
    }

    Timer {
        id: brightnessTimer
        interval: 1000
        onTriggered: {
            if (root.state !== "brightness") return
            if (root.isHoverOverrideActive()) brightnessTimer.restart()
            else root.showClock()
        }
    }
}
