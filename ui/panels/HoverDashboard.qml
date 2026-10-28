import QtQuick
import Quickshell
import "../HoverDashboard/Slides/ClockSlide/"
import "../HoverDashboard/Slides/MediaSlide/"
import "../HoverDashboard/Slides/SettingsSlide/"
import "../HoverDashboard/Slides/NotificationSlide/"
import "../HoverDashboard/Slides/"
import "../HoverDashboard/components/"

Item {
    id: dashboardRoot
    anchors.fill: parent
    clip: true

    property int activeTab: 0
    property int defaultTab: 0
    property string subState: "default"
    property var notificationManager
    property var settings
    // Set by MainPanel while the hover pill is actually showing. `visible` on
    // a Loader's child stays true when the loader is hidden, so it cannot be
    // used to gate timers.
    property bool isOpen: false

    signal layoutChanged(int w, int h)

    readonly property var layoutRegistry: {
        0: {
            "default":       { w: 550, h: 250 },
            "calendar":      { w: 530, h: 350 }
        },
        1: { "default":      { w: 550, h: 250 } },
        2: {
            "default":       { w: 450, h: 400 },
            "wifi_expanded": { w: 400, h: 450 },
            "bt_expanded":   { w: 400, h: 450 }
        },
        3: { "default":      { w: 550, h: 400 } }
    }

    property int targetWidth: layoutRegistry[activeTab]?.[subState]?.w ?? layoutRegistry[activeTab]?.["default"]?.w ?? 350
    property int targetHeight: layoutRegistry[activeTab]?.[subState]?.h ?? layoutRegistry[activeTab]?.["default"]?.h ?? 180

    onTargetWidthChanged: layoutChanged(targetWidth, targetHeight)
    onTargetHeightChanged: layoutChanged(targetWidth, targetHeight)

    Component.onCompleted: activeTab = defaultTab

    DashboardNavBar {
        activeTab: dashboardRoot.activeTab
        onTabChanged: (tab) => {
            dashboardRoot.activeTab = tab
            dashboardRoot.subState = "default"
        }
    }

    ClockSlide {
        visible: dashboardRoot.activeTab === 0 && dashboardRoot.subState === "default"
        isOpen: dashboardRoot.isOpen
        anchors.fill: parent
        currentSubState: dashboardRoot.subState
        settings: dashboardRoot.settings

        onRequestStateChange: (targetState) => {
            dashboardRoot.subState = targetState
        }
    }

    // Tab 0: Calendar Sub-View Overlay
    CalendarWidget {
        visible: dashboardRoot.activeTab === 0 && dashboardRoot.subState === "calendar"
        anchors.fill: parent

        onRequestClose: {
            dashboardRoot.subState = "default"
        }
    }

    MediaSlide {
        visible: dashboardRoot.activeTab === 1
        isOpen: dashboardRoot.isOpen
    }

    SettingsSlide {
        visible: dashboardRoot.activeTab === 2
        anchors.fill: parent
        isOpen: dashboardRoot.isOpen

        currentSubState: dashboardRoot.subState

        onRequestStateChange: (targetState) => {
            dashboardRoot.subState = targetState
        }
    }

    NotificationSlide {
        visible: dashboardRoot.activeTab === 3
        anchors.fill: parent
        manager: dashboardRoot.notificationManager
    }
}
