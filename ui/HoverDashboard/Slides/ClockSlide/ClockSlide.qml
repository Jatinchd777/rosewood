import QtQuick
import Quickshell
import Quickshell.Io
import "../../components/"
import "../../../global/"
import "../../../../ui/global/"

Item {
    id: clockSlide
    anchors.fill: parent

    property string currentSubState: "default"
    property bool isOpen: false
    readonly property bool isActive: isOpen && visible
    signal requestStateChange(string targetState)

    property color accent: theme.primary
    property var settings

    readonly property bool use24h: settings ? settings.clockFormat === "24h" : false
    readonly property bool showSeconds: settings ? settings.showSeconds : true
    readonly property bool showDate: settings ? settings.showDate : true

    readonly property string datePattern: {
        const format = settings ? settings.dateFormat : "long"
        if (format === "short")
            return "ddd, d MMM"
        if (format === "iso")
            return "yyyy-MM-dd"
        return "dddd, d MMMM"
    }

    opacity: visible ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutQuad
        }
    }

    SystemClock {
        id: clock
        precision: clockSlide.isActive && clockSlide.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    WeatherWidget {
        accent: clockSlide.accent
        location: clockSlide.settings ? clockSlide.settings.weatherLocation : "Chandigarh"
        unit: clockSlide.settings ? clockSlide.settings.weatherUnit : "metric"
        showWeather: clockSlide.settings ? clockSlide.settings.showWeather : true
        refreshMinutes: clockSlide.settings ? clockSlide.settings.weatherRefresh : 30
        active: clockSlide.isActive
        visible: clockSlide.settings ? clockSlide.settings.showWeather : true

        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.verticalCenter: clockColumn.verticalCenter
    }

    CpuWidget {
        accent: clockSlide.accent
        active: clockSlide.isActive

        anchors.left: parent.left
        anchors.leftMargin: 55
        anchors.verticalCenter: clockColumn.verticalCenter
    }

    Item {
        id: layoutAnchor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 70
        width: 1
        height: 1
        opacity: 0
    }

    RamWidget {
        accent: clockSlide.accent
        active: clockSlide.isActive

        anchors.right: layoutAnchor.left
        anchors.rightMargin: 157

        anchors.verticalCenter: layoutAnchor.verticalCenter
        anchors.verticalCenterOffset: -25
    }

    PingWidget {
        accent: clockSlide.accent
        active: clockSlide.isActive

        anchors.left: layoutAnchor.right
        anchors.leftMargin: 170

        anchors.verticalCenter: layoutAnchor.verticalCenter
        anchors.verticalCenterOffset: -25
    }

    Column {
        id: clockColumn

        spacing: 4

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110

        Text {
            text: Qt.formatDateTime(clock.date, clockSlide.use24h
                ? (clockSlide.showSeconds ? "HH:mm:ss" : "HH:mm")
                : (clockSlide.showSeconds ? "hh:mm:ss AP" : "hh:mm AP"))

            color: clockSlide.accent
            font.family: "JetBrains Mono"
            font.pixelSize: 30
            font.bold: true

            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            visible: clockSlide.showDate
            text: Qt.formatDateTime(clock.date, clockSlide.datePattern)

            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: 14
            font.weight: Font.Medium

            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        id: clockClickArea
        anchors.fill: clockColumn
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                clockSlide.requestStateChange("calendar")
            }
        }

        onDoubleClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                clockSlide.requestStateChange("calendar")
            }
        }
    }

    Item {
        id: metricsContainer

        width: 350
        height: 30

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30

        BatteryWidget {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Workspace {
            id: dashboardWorkspaces
            count: clockSlide.settings ? clockSlide.settings.workspaceCount : 10
        }

        WifiWidget {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    UserWidget {
        accent: clockSlide.accent

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 40
    }

    HostWidget {
        accent: clockSlide.accent

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
    }
}

