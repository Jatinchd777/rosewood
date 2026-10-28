pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "./core/Logic/"
import "./components/"
import "./pages/"

FloatingWindow {
    id: window

    visible: true
    title: "Rosewood Settings"
    color: "transparent"
    implicitWidth: 1020
    implicitHeight: 720
    minimumSize.width: 860
    minimumSize.height: 560

    ThemeEngine {
        id: colors
    }

    RosewoodSettings {
        id: store
        writeable: true
    }

    property int currentPage: 0
    property bool confirmReset: false

    readonly property var pages: [
        { icon: "󰕮", label: "Dashboard" },
        { icon: "󰍹", label: "Bar" },
        { icon: "󰀻", label: "Launcher" },
        { icon: "󰸉", label: "Wallpaper" },
        { icon: "󰂚", label: "Notifications" },
        { icon: "󰌾", label: "Lock Screen" }
    ]

    readonly property string statusText: store.parseError !== ""
        ? "Invalid JSON"
        : (store.pendingSave ? "Saving…" : "Saved")

    readonly property color statusColor: store.parseError !== ""
        ? colors.error
        : (store.pendingSave ? colors.on_surface_variant : colors.primary)

    // Wayland clients cannot float, place, or raise themselves. Hyprland owns
    // that, so reapply the floating geometry whenever the window is shown.
    readonly property string placeScript: (Quickshell.env("HOME") || "") + "/.config/quickshell/settings/place.sh"

    function placeSelf(): void {
        if (window.visible)
            Quickshell.execDetached(["bash", window.placeScript])
    }

    function showAndFocus(): void {
        window.visible = true
        placeTimer.restart()
    }

    Timer {
        id: placeTimer
        interval: 100
        onTriggered: window.placeSelf()
    }

    IpcHandler {
        target: "settings"

        function open(): void {
            window.showAndFocus()
        }

        function hide(): void {
            window.visible = false
        }

        function toggle(): void {
            if (window.visible)
                window.visible = false
            else
                window.showAndFocus()
        }

        function page(index: int): void {
            if (index >= 0 && index < window.pages.length)
                window.currentPage = index
        }

        function reset(): void {
            store.resetDefaults()
        }
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "Escape"
        enabled: window.confirmReset
        onActivated: window.confirmReset = false
    }

    onClosed: Qt.quit()

    // Same surface treatment as the top pill: the palette background at the
    // shared bar opacity, so the desktop shows through the settings window at
    // exactly the same strength as the rest of rosewood.
    Rectangle {
        id: surface

        anchors.fill: parent
        radius: 20
        color: Qt.alpha(colors.background, store.backgroundOpacity)
        border.width: 1
        border.color: Qt.alpha(colors.surface_variant, 0.35)

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 1
            spacing: 0

            Item {
                Layout.preferredWidth: 224
                Layout.fillHeight: true

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: Qt.alpha(colors.surface_variant, 0.25)
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 18
                    anchors.bottomMargin: 16
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 20
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38
                            radius: 11
                            color: colors.primary

                            Text {
                                anchors.centerIn: parent
                                text: "󰣇"
                                color: colors.on_primary
                                font.family: "JetBrains Mono Nerd Font"
                                font.pixelSize: 21
                            }
                        }

                        ColumnLayout {
                            spacing: 0

                            Text {
                                text: "rosewood"
                                color: colors.on_background
                                font.family: "JetBrains Mono"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                font.letterSpacing: -0.3
                            }

                            Text {
                                text: "settings"
                                color: colors.on_surface_variant
                                font.family: "JetBrains Mono"
                                font.pixelSize: 10
                                font.letterSpacing: 1.4
                            }
                        }
                    }

                    Repeater {
                        model: window.pages

                        SidebarButton {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            theme: colors
                            icon: modelData.icon
                            label: modelData.label
                            active: window.currentPage === index
                            onClicked: window.currentPage = index
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 8
                        color: Qt.alpha(colors.surface, 0.4)
                        border.width: 1
                        border.color: Qt.alpha(colors.surface_variant, 0.3)

                        Row {
                            anchors.centerIn: parent
                            spacing: 7

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                anchors.verticalCenter: parent.verticalCenter
                                color: window.statusColor
                            }

                            Text {
                                text: window.statusText
                                color: window.statusColor
                                font.family: "JetBrains Mono"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 2
                        text: "settings.json"
                        color: Qt.alpha(colors.on_surface_variant, 0.7)
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        elide: Text.ElideMiddle

                        HoverHandler {
                            id: pathHover
                        }

                        ToolTip.visible: pathHover.hovered
                        ToolTip.delay: 400
                        ToolTip.text: store.path
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        Layout.topMargin: 6
                        theme: colors
                        icon: "󰑐"
                        text: "Reset defaults"
                        onClicked: window.confirmReset = true
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        theme: colors
                        icon: "󰅖"
                        text: "Close"
                        onClicked: Qt.quit()
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: window.currentPage

                DashboardPage {
                    theme: colors
                    settings: store
                }

                BarPage {
                    theme: colors
                    settings: store
                }

                LauncherPage {
                    theme: colors
                    settings: store
                }

                WallpaperPage {
                    theme: colors
                    settings: store
                }

                NotificationsPage {
                    theme: colors
                    settings: store
                }

                LockPage {
                    theme: colors
                    settings: store
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            z: 100
            visible: window.confirmReset
            radius: surface.radius
            color: Qt.alpha("#000000", 0.45)

            MouseArea {
                anchors.fill: parent
                onClicked: window.confirmReset = false
            }

            Rectangle {
                anchors.centerIn: parent
                width: 390
                height: resetLayout.implicitHeight + 44
                radius: 14
                color: Qt.alpha(colors.background, 0.96)
                border.width: 1
                border.color: Qt.alpha(colors.surface_variant, 0.4)

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    id: resetLayout

                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Reset settings?"
                        color: colors.on_background
                        font.family: "JetBrains Mono"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "All values will return to their defaults. This cannot be undone."
                        color: colors.on_surface_variant
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        lineHeight: 1.25
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        Layout.topMargin: 8
                        spacing: 8

                        ActionButton {
                            theme: colors
                            text: "Cancel"
                            onClicked: window.confirmReset = false
                        }

                        ActionButton {
                            theme: colors
                            text: "Reset"
                            primary: true
                            onClicked: {
                                store.resetDefaults()
                                window.confirmReset = false
                            }
                        }
                    }
                }
            }
        }
    }
}
