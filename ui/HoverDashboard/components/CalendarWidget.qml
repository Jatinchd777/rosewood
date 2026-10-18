import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent

    signal requestClose()

    property color accent: theme.primary
    property color cardColor: Qt.alpha(theme.surface, 0.66)
    property color borderColor: Qt.alpha(theme.surface_variant, 0.66)
    property color textMuted: theme.on_surface_variant

    property date viewDate: new Date()
    readonly property date today: new Date()

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfWeek(year, month) {
        let day = new Date(year, month, 1).getDay()
        return (day === 0) ? 6 : day - 1     
    }

    function changeMonth(delta) {
        let d = new Date(viewDate.getFullYear(), viewDate.getMonth() + delta, 1)
        viewDate = d
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            RowLayout {
                spacing: 8

                Text {
                    text: "󰅁"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 14
                    color: theme.on_surface

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changeMonth(-1)
                    }
                }

                Text {
                    text: viewDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                    font.bold: true
                    color: theme.on_surface
                }

                Text {
                    text: "󰅂"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 14
                    color: theme.on_surface

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changeMonth(1)
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "󰁍 Back"
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 12
                color: theme.on_surface

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.requestClose()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 0
        }

        Grid {
            Layout.fillWidth: true
            columns: 7
            spacing: 0

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                delegate: Item {
                    width: (root.width - 32) / 7
                    height: 24

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: "JetBrains Mono nerd font"
                        font.pixelSize: 14
                        font.bold: true
                        color: root.accent
                    }
                }
            }
        }

        Grid {
            id: calendarGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            spacing: 0

            Repeater {
                model: 42

                delegate: Item {
                    width: (root.width - 32) / 7
                    height: (calendarGrid.height) / 6

                    property int year: root.viewDate.getFullYear()
                    property int month: root.viewDate.getMonth()
                    property int firstDay: root.firstDayOfWeek(year, month)
                    property int totalDays: root.daysInMonth(year, month)
                    property int prevMonthDays: root.daysInMonth(year, month - 1)

                    property int dayNumber: {
                        if (index < firstDay) {
                            return prevMonthDays - firstDay + index + 1
                        } else if (index >= firstDay + totalDays) {
                            return index - firstDay - totalDays + 1
                        } else {
                            return index - firstDay + 1
                        }
                    }

                    property bool isCurrentMonth: index >= firstDay && index < (firstDay + totalDays)
                    property bool isToday: isCurrentMonth
                    && dayNumber === root.today.getDate()
                    && month === root.today.getMonth()
                    && year === root.today.getFullYear()

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(parent.width - 4, parent.height - 4)
                        height: width
                        radius: width / 2
                        color: isToday ? root.accent : "transparent"
                        border.color: isToday ? root.accent : "transparent"
                        border.width: 1
                    }

                    Text {
                        anchors.centerIn: parent
                        text: dayNumber
                        font.family: "JetBrains Mono nerd font"
                        font.pixelSize: 12
                        font.bold: isToday

                        color: {
                            if (isToday) return theme.on_primary
                            if (isCurrentMonth) return theme.on_surface
                            return root.textMuted
                        }
                    }
                }
            }
        }
    }
}
