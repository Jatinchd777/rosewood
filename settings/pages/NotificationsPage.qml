import QtQuick
import "../components/"

PageContent {
    id: page

    property var settings

    title: "Notifications"
    description: "Toast lifetime and notification history."

    SectionTitle {
        theme: page.theme
        text: "TOASTS"
    }

    SettingSlider {
        theme: page.theme
        title: "Toast duration"
        description: "How long a notification stays on the pill after it arrives."
        from: 1000
        to: 30000
        stepSize: 500
        value: page.settings.notificationTimeout
        valueText: (Math.round(page.settings.notificationTimeout / 100) / 10).toFixed(1) + " s"
        onMoved: (value) => page.settings.notificationTimeout = Math.round(value)
    }

    SectionTitle {
        theme: page.theme
        text: "HISTORY"
    }

    SettingToggle {
        theme: page.theme
        title: "Keep expired notifications"
        description: "Expired toasts stay in the dashboard history until you dismiss them."
        checked: page.settings.keepExpiredNotifications
        onToggled: (checked) => page.settings.keepExpiredNotifications = checked
    }

    InfoNote {
        theme: page.theme
        text: "When this is off, notifications are removed from history as soon as their toast expires."
    }
}
