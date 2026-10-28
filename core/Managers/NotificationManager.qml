import QtQuick
import Quickshell
import Quickshell.Services.Notifications as Notifs

// Single owner of the org.freedesktop.Notifications bus name. Both the pill
// toast and the dashboard history read from this object, which avoids two
// NotificationServers competing for the same name.
Item {
    id: root
    visible: false

    property var stateEngine
    property var settings

    property var latest: null
    property string latestSummary: ""
    property string latestBody: ""
    property string latestAppName: ""
    property int latestUrgency: 1

    property alias history: historyModel

    readonly property int count: historyModel.count

    function dismissLatest() {
        if (root.latest)
            root.latest.dismiss()
        root.latest = null
    }

    function dismissAt(index) {
        if (index < 0 || index >= historyModel.count)
            return

        const item = historyModel.get(index)
        if (item.notifObject) {
            // `dismiss()` emits `closed`, which removes the matching row via
            // notificationClosed(). Removing here as well would delete the
            // next notification from the list.
            item.notifObject.dismiss()
        } else {
            historyModel.remove(index)
        }
    }

    function clearAll() {
        for (let i = historyModel.count - 1; i >= 0; --i) {
            const item = historyModel.get(i)
            if (item.notifObject)
                item.notifObject.dismiss()
        }

        historyModel.clear()
        root.latest = null
    }

    function notificationClosed(notification, reason) {
        if (root.latest === notification)
            root.latest = null

        // Expiration should only hide the toast. Keep the notification in the
        // dashboard history until the user dismisses it, unless the user turns
        // that behavior off in settings.
        if (reason === Notifs.NotificationCloseReason.Expired
                && (!root.settings || root.settings.keepExpiredNotifications)) {
            for (let i = 0; i < historyModel.count; i++) {
                if (historyModel.get(i).notifObject === notification) {
                    historyModel.setProperty(i, "notifObject", null)
                    break
                }
            }
            return
        }

        root.removeNotification(notification)
    }

    function removeNotification(notification) {
        for (let i = 0; i < historyModel.count; i++) {
            if (historyModel.get(i).notifObject === notification) {
                historyModel.remove(i)
                break
            }
        }

        if (root.latest === notification)
            root.latest = null
    }

    ListModel { id: historyModel }

    Notifs.NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true

        onNotification: (notification) => {
            // Tracked notifications survive the signal call and can be
            // dismissed later from the dashboard history.
            notification.tracked = true

            root.latest = notification
            root.latestSummary = notification.summary || "Notification"
            root.latestBody = notification.body || ""
            root.latestAppName = notification.appName || "System"
            root.latestUrgency = notification.urgency

            historyModel.insert(0, {
                "notifSummary": notification.summary || "",
                "notifBody": notification.body || "",
                "notifAppName": notification.appName || "",
                "notifUrgency": notification.urgency,
                "notifObject": notification,
                "isExpanded": true
            })

            // Keep memory bounded even when notifications are never dismissed.
            if (historyModel.count > 50) {
                const oldest = historyModel.get(historyModel.count - 1)
                if (oldest.notifObject)
                    oldest.notifObject.dismiss()
                historyModel.remove(historyModel.count - 1)
            }

            if (root.stateEngine)
                root.stateEngine.showNotifications()

            notification.closed.connect((reason) => root.notificationClosed(notification, reason))
        }
    }
}
