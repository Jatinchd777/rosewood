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
    property bool showDate: true
    property string dateFormat: "long"
    property string weatherLocation: "Chandigarh"
    property string weatherUnit: "metric"
    property bool showWeather: true
    property int weatherRefresh: 30
    property int defaultDashboardTab: 0

    // Bar
    property int marginTop: 5
    property int exclusiveZone: 26
    property real backgroundOpacity: 0.65
    property int statusDuration: 1000
    property int workspaceCount: 10

    // Launcher
    property int launcherColumns: 2
    property int launcherMaxResults: 50
    property int launcherIconSize: 32

    // Wallpaper
    property string wallpaperDirectory: "~/Pictures/wallpapers"
    property real wallpaperTransition: 0.75
    property string wallpaperTransitionType: "random"
    property string wallpaperResize: "crop"

    // Notifications
    property int notificationTimeout: 3000
    property bool keepExpiredNotifications: true
    property bool doNotDisturb: false
    property int notificationHistoryLimit: 50

    // Lock screen
    property string lockMonitor: "eDP-1"
    property bool lockUseScreenshot: true
    property int lockBlur: 32
    property real lockDim: 0.45

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
        root.showDate = root.boolOr(dashboard.showDate, true)
        root.dateFormat = root.enumOr(dashboard.dateFormat, ["long", "short", "iso"], "long")
        root.weatherLocation = root.stringOr(dashboard.weatherLocation, "Chandigarh")
        root.weatherUnit = root.enumOr(dashboard.weatherUnit, ["metric", "imperial"], "metric")
        root.showWeather = root.boolOr(dashboard.showWeather, true)
        root.weatherRefresh = Math.round(root.numberOr(dashboard.weatherRefreshMinutes, 30, 5, 120))
        root.defaultDashboardTab = Math.round(root.numberOr(dashboard.defaultDashboardTab, 0, 0, 3))

        root.marginTop = Math.round(root.numberOr(bar.marginTop, 5, 0, 40))
        root.exclusiveZone = Math.round(root.numberOr(bar.exclusiveZone, 26, 0, 80))
        root.backgroundOpacity = root.numberOr(bar.backgroundOpacity, 0.65, 0.2, 1)
        root.statusDuration = Math.round(root.numberOr(bar.statusDuration, 1000, 500, 5000))
        root.workspaceCount = Math.round(root.numberOr(bar.workspaceCount, 10, 1, 10))

        root.launcherColumns = Math.round(root.numberOr(launcher.columns, 2, 1, 4))
        root.launcherMaxResults = Math.round(root.numberOr(launcher.maxResults, 50, 5, 100))
        root.launcherIconSize = Math.round(root.numberOr(launcher.iconSize, 32, 20, 48))

        root.wallpaperDirectory = root.stringOr(wallpaper.directory, "~/Pictures/wallpapers")
        root.wallpaperTransition = root.numberOr(wallpaper.transitionDuration, 0.75, 0, 2)
        root.wallpaperTransitionType = root.enumOr(wallpaper.transitionType, ["random", "fade", "wipe", "grow", "wave"], "random")
        root.wallpaperResize = root.enumOr(wallpaper.resizeMode, ["crop", "fit", "stretch", "no"], "crop")

        root.notificationTimeout = Math.round(root.numberOr(notifications.toastTimeout, 3000, 1000, 30000))
        root.keepExpiredNotifications = root.boolOr(notifications.keepExpired, true)
        root.doNotDisturb = root.boolOr(notifications.doNotDisturb, false)
        root.notificationHistoryLimit = Math.round(root.numberOr(notifications.historyLimit, 50, 10, 200))

        root.lockMonitor = root.stringOr(lock.monitor, "eDP-1")
        root.lockUseScreenshot = root.boolOr(lock.useScreenshot, true)
        root.lockBlur = Math.round(root.numberOr(lock.blur, 32, 0, 64))
        root.lockDim = root.numberOr(lock.dim, 0.45, 0, 0.85)

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
                "showDate": root.showDate,
                "dateFormat": root.dateFormat,
                "weatherLocation": root.weatherLocation,
                "weatherUnit": root.weatherUnit,
                "showWeather": root.showWeather,
                "weatherRefreshMinutes": root.weatherRefresh,
                "defaultDashboardTab": root.defaultDashboardTab
            },
            "bar": {
                "marginTop": root.marginTop,
                "exclusiveZone": root.exclusiveZone,
                "backgroundOpacity": root.backgroundOpacity,
                "statusDuration": root.statusDuration,
                "workspaceCount": root.workspaceCount
            },
            "launcher": {
                "columns": root.launcherColumns,
                "maxResults": root.launcherMaxResults,
                "iconSize": root.launcherIconSize
            },
            "wallpaper": {
                "directory": root.wallpaperDirectory,
                "transitionDuration": root.wallpaperTransition,
                "transitionType": root.wallpaperTransitionType,
                "resizeMode": root.wallpaperResize
            },
            "notifications": {
                "toastTimeout": root.notificationTimeout,
                "keepExpired": root.keepExpiredNotifications,
                "doNotDisturb": root.doNotDisturb,
                "historyLimit": root.notificationHistoryLimit
            },
            "lock": {
                "monitor": root.lockMonitor,
                "useScreenshot": root.lockUseScreenshot,
                "blur": root.lockBlur,
                "dim": root.lockDim
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
        root.showDate = true
        root.dateFormat = "long"
        root.weatherLocation = "Chandigarh"
        root.weatherUnit = "metric"
        root.showWeather = true
        root.weatherRefresh = 30
        root.defaultDashboardTab = 0
        root.marginTop = 5
        root.exclusiveZone = 26
        root.backgroundOpacity = 0.65
        root.statusDuration = 1000
        root.workspaceCount = 10
        root.launcherColumns = 2
        root.launcherMaxResults = 50
        root.launcherIconSize = 32
        root.wallpaperDirectory = "~/Pictures/wallpapers"
        root.wallpaperTransition = 0.75
        root.wallpaperTransitionType = "random"
        root.wallpaperResize = "crop"
        root.notificationTimeout = 3000
        root.keepExpiredNotifications = true
        root.doNotDisturb = false
        root.notificationHistoryLimit = 50
        root.lockMonitor = "eDP-1"
        root.lockUseScreenshot = true
        root.lockBlur = 32
        root.lockDim = 0.45

        root.applying = false
        root.save()
    }

    onClockFormatChanged: root.scheduleSave()
    onShowSecondsChanged: root.scheduleSave()
    onShowDateChanged: root.scheduleSave()
    onDateFormatChanged: root.scheduleSave()
    onWeatherLocationChanged: root.scheduleSave()
    onWeatherUnitChanged: root.scheduleSave()
    onShowWeatherChanged: root.scheduleSave()
    onWeatherRefreshChanged: root.scheduleSave()
    onDefaultDashboardTabChanged: root.scheduleSave()
    onMarginTopChanged: root.scheduleSave()
    onExclusiveZoneChanged: root.scheduleSave()
    onBackgroundOpacityChanged: root.scheduleSave()
    onStatusDurationChanged: root.scheduleSave()
    onWorkspaceCountChanged: root.scheduleSave()
    onLauncherColumnsChanged: root.scheduleSave()
    onLauncherMaxResultsChanged: root.scheduleSave()
    onLauncherIconSizeChanged: root.scheduleSave()
    onWallpaperDirectoryChanged: root.scheduleSave()
    onWallpaperTransitionChanged: root.scheduleSave()
    onWallpaperTransitionTypeChanged: root.scheduleSave()
    onWallpaperResizeChanged: root.scheduleSave()
    onNotificationTimeoutChanged: root.scheduleSave()
    onKeepExpiredNotificationsChanged: root.scheduleSave()
    onDoNotDisturbChanged: root.scheduleSave()
    onNotificationHistoryLimitChanged: root.scheduleSave()
    onLockMonitorChanged: root.scheduleSave()
    onLockUseScreenshotChanged: root.scheduleSave()
    onLockBlurChanged: root.scheduleSave()
    onLockDimChanged: root.scheduleSave()

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
