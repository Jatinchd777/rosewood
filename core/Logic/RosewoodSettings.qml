import QtQuick
import Quickshell
import Quickshell.Io

// Shared user settings store. The main shell instantiates this read-only and
// reacts to file changes; settings/settings.qml instantiates it writeable and
// saves through the same FileView. Keeping the schema here means there is only
// one place that knows how settings.json maps to QML properties.
Item {
    id: root

    property bool writeable: false

    readonly property string home: Quickshell.env("HOME") || ""
    property string path: home + "/.config/quickshell/settings.json"

    // Dashboard
    property string clockFormat: "12h"
    property bool showSeconds: true
    property string weatherLocation: "Chandigarh"
    property string weatherUnit: "metric"
    property int defaultDashboardTab: 0

    // Bar
    property int marginTop: 5
    property int exclusiveZone: 26
    property real backgroundOpacity: 0.65

    // Launcher
    property int launcherColumns: 2

    // Wallpaper
    property string wallpaperDirectory: "~/Pictures/wallpapers"
    property real wallpaperTransition: 0.75

    // Notifications
    property int notificationTimeout: 3000
    property bool keepExpiredNotifications: true

    // Lock screen
    property string lockMonitor: "eDP-1"

    readonly property string wallpaperDirectoryResolved: root.resolvePath(root.wallpaperDirectory)
    readonly property bool pendingSave: saveTimer.running

    property bool loaded: false
    property bool applying: false
    property string parseError: ""
    property int saveRevision: 0

    signal saved()

    function resolvePath(value) {
        if (!value)
            return ""
        if (value === "~")
            return root.home
        if (value.startsWith("~/"))
            return root.home + value.substring(1)
        return value
    }

    function objectOr(value, fallback) {
        return value && typeof value === "object" ? value : fallback
    }

    function stringOr(value, fallback) {
        return typeof value === "string" && value.trim().length > 0 ? value : fallback
    }

    function boolOr(value, fallback) {
        return typeof value === "boolean" ? value : fallback
    }

    function numberOr(value, fallback, minimum, maximum) {
        const number = Number(value)
        if (!isFinite(number))
            return fallback
        return Math.min(maximum, Math.max(minimum, number))
    }

    function enumOr(value, allowed, fallback) {
        return allowed.indexOf(value) !== -1 ? value : fallback
    }

    function apply(source) {
        if (!source || source.trim() === "") {
            root.parseError = ""
            root.loaded = true
            // The settings app creates the file with defaults on first run.
            if (root.writeable)
                root.save()
            return
        }

        let data
        try {
            data = JSON.parse(source)
        } catch (error) {
            root.parseError = "settings.json is not valid JSON: " + error
            root.loaded = true
            return
        }

        const dashboard = root.objectOr(data.dashboard, {})
        const bar = root.objectOr(data.bar, {})
        const launcher = root.objectOr(data.launcher, {})
        const wallpaper = root.objectOr(data.wallpaper, {})
        const notifications = root.objectOr(data.notifications, {})
        const lock = root.objectOr(data.lock, {})

        root.applying = true

        root.clockFormat = root.enumOr(dashboard.clockFormat, ["12h", "24h"], "12h")
        root.showSeconds = root.boolOr(dashboard.showSeconds, true)
        root.weatherLocation = root.stringOr(dashboard.weatherLocation, "Chandigarh")
        root.weatherUnit = root.enumOr(dashboard.weatherUnit, ["metric", "imperial"], "metric")
        root.defaultDashboardTab = Math.round(root.numberOr(dashboard.defaultDashboardTab, 0, 0, 3))

        root.marginTop = Math.round(root.numberOr(bar.marginTop, 5, 0, 40))
        root.exclusiveZone = Math.round(root.numberOr(bar.exclusiveZone, 26, 0, 80))
        root.backgroundOpacity = root.numberOr(bar.backgroundOpacity, 0.65, 0.2, 1)

        root.launcherColumns = Math.round(root.numberOr(launcher.columns, 2, 1, 4))

        root.wallpaperDirectory = root.stringOr(wallpaper.directory, "~/Pictures/wallpapers")
        root.wallpaperTransition = root.numberOr(wallpaper.transitionDuration, 0.75, 0, 2)

        root.notificationTimeout = Math.round(root.numberOr(notifications.toastTimeout, 3000, 1000, 30000))
        root.keepExpiredNotifications = root.boolOr(notifications.keepExpired, true)

        root.lockMonitor = root.stringOr(lock.monitor, "eDP-1")

        root.applying = false
        root.parseError = ""
        root.loaded = true
    }

    function toObject() {
        return {
            "version": 1,
            "dashboard": {
                "clockFormat": root.clockFormat,
                "showSeconds": root.showSeconds,
                "weatherLocation": root.weatherLocation,
                "weatherUnit": root.weatherUnit,
                "defaultDashboardTab": root.defaultDashboardTab
            },
            "bar": {
                "marginTop": root.marginTop,
                "exclusiveZone": root.exclusiveZone,
                "backgroundOpacity": root.backgroundOpacity
            },
            "launcher": {
                "columns": root.launcherColumns
            },
            "wallpaper": {
                "directory": root.wallpaperDirectory,
                "transitionDuration": root.wallpaperTransition
            },
            "notifications": {
                "toastTimeout": root.notificationTimeout,
                "keepExpired": root.keepExpiredNotifications
            },
            "lock": {
                "monitor": root.lockMonitor
            }
        }
    }

    function save() {
        if (!root.writeable || !root.loaded)
            return

        file.setText(JSON.stringify(root.toObject(), null, 2) + "\n")
        root.saveRevision++
        root.saved()
    }

    function scheduleSave() {
        if (!root.writeable || !root.loaded || root.applying)
            return
        saveTimer.restart()
    }

    function resetDefaults() {
        root.applying = true

        root.clockFormat = "12h"
        root.showSeconds = true
        root.weatherLocation = "Chandigarh"
        root.weatherUnit = "metric"
        root.defaultDashboardTab = 0
        root.marginTop = 5
        root.exclusiveZone = 26
        root.backgroundOpacity = 0.65
        root.launcherColumns = 2
        root.wallpaperDirectory = "~/Pictures/wallpapers"
        root.wallpaperTransition = 0.75
        root.notificationTimeout = 3000
        root.keepExpiredNotifications = true
        root.lockMonitor = "eDP-1"

        root.applying = false
        root.save()
    }

    onClockFormatChanged: root.scheduleSave()
    onShowSecondsChanged: root.scheduleSave()
    onWeatherLocationChanged: root.scheduleSave()
    onWeatherUnitChanged: root.scheduleSave()
    onDefaultDashboardTabChanged: root.scheduleSave()
    onMarginTopChanged: root.scheduleSave()
    onExclusiveZoneChanged: root.scheduleSave()
    onBackgroundOpacityChanged: root.scheduleSave()
    onLauncherColumnsChanged: root.scheduleSave()
    onWallpaperDirectoryChanged: root.scheduleSave()
    onWallpaperTransitionChanged: root.scheduleSave()
    onNotificationTimeoutChanged: root.scheduleSave()
    onKeepExpiredNotificationsChanged: root.scheduleSave()
    onLockMonitorChanged: root.scheduleSave()

    Timer {
        id: saveTimer
        interval: 250
        onTriggered: root.save()
    }

    FileView {
        id: file
        path: root.path
        printErrors: false
        watchChanges: true
        onFileChanged: file.reload()
        onTextChanged: root.apply(file.text())
    }
}
