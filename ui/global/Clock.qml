import QtQuick
import Quickshell
import QtQuick.Layouts
import "../core/Logic"

Row {
    id: root
    spacing: 10
    anchors.horizontalCenterOffset: -6
    anchors.centerIn: parent

    property color accent: theme.primary
    property color textColor: theme.on_background

    property string statusIcon: {
        const hour = clock.date.getHours()

        if (hour >= 5 && hour < 12)
        return "󰖨"
        if (hour >= 12 && hour < 17)
        return "󰖙"
        if (hour >= 17 && hour < 20)
        return "󰖛"
        return "󰖔"
    }

    Text {
        text: root.statusIcon
        color: root.accent

        font.family: "JetBrains Mono Nerd Font"
        y:0
        font.pixelSize: 15
        font.weight: Font.Medium
    }

    Text {
        text: Qt.formatDateTime(clock.date, "hh:mm AP")
        color: root.textColor

        y: 3
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 11
        font.weight: Font.Medium
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 500
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
