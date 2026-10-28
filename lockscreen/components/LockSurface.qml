import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Effects
import "../core/"

Rectangle {
    id: root
    anchors.fill: parent
    color: "black"

    required property var context
    property bool screenshot: false

    readonly property string screenshotPath: Quickshell.env("QS_LOCK_BG") || ""

    // 🎬 Animation State Management
    property bool animateIn: false

    // 🔒 The screen stays active. No fake hiding during PAM checks.
    readonly property bool active: root.animateIn

    // Defer entrance trigger by 1 frame for a clean render pass
    Timer {
        id: animInitTimer
        interval: 16
        repeat: false
        onTriggered: root.animateIn = true
    }

    Component.onCompleted: animInitTimer.start()

    // Theme / Colors
    ThemeEngine { id: theme }

    readonly property color foreColor: theme.on_surface
    readonly property color failColor: theme.error

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    readonly property var clock: systemClock.date
    readonly property string userName: Quickshell.env("USER") || ""
    property string songText: ""

    // Auth visibility state
    property bool authenticating: field.shown || passwordBox.text.length > 0 || root.context.showFailure

    // ----- Clock Logic -----
    readonly property string hours: String(root.clock.getHours()).padStart(2, "0")
    readonly property string minutes: String(root.clock.getMinutes()).padStart(2, "0")

    // ---------- BACKGROUND LAYER 1: Crisp Image ----------
    Item {
        anchors.fill: parent

        Image {
            id: wallpaper
            anchors.fill: parent
            source: root.screenshot && root.screenshotPath
            ? root.screenshotPath
            : (theme.currentWallpaper ? theme.currentWallpaper : "")
            fillMode: Image.PreserveAspectCrop
            cache: false

            onStatusChanged: {
                if (root.screenshot && root.screenshotPath && status === Image.Error) {
                    wallpaper.source = theme.currentWallpaper ? theme.currentWallpaper : ""
                }
            }
        }

        // ---------- BACKGROUND LAYER 2: Pre-blurred Overlay (Fade In) ----------
        Image {
            anchors.fill: parent
            source: wallpaper.source
            fillMode: Image.PreserveAspectCrop
            cache: false
            opacity: root.active ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutQuart
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: 32
                blur: 1.0
                contrast: 0.20
                blurMultiplier: 0.5
            }
        }

        // 🌑 Dark Vignette Overlay
        Rectangle {
            anchors.fill: parent
            color: Qt.alpha("black", 0.45)
            opacity: root.active ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutQuart
                }
            }
        }
    }

    // Key event capture to wake up input on any press
    Item {
        focus: true
        anchors.fill: parent
        Keys.onPressed: (event) => {
            if (!field.shown) {
                field.shown = true
                passwordBox.forceActiveFocus()
            }
        }
    }

    // ---------- CENTER PIECE: CLOCK & AUTH BLOCK ----------
    ColumnLayout {
        id: centerStack
        anchors.centerIn: parent
        spacing: 28

        opacity: root.active ? 1.0 : 0.0

        transform: Translate {
            y: root.active ? 0 : -24
            Behavior on y {
                NumberAnimation {
                    duration: 550
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuart
            }
        }

        // 1. Centered Clock & Date
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    text: root.hours
                    color: root.foreColor
                    font.family: "JetBrainsMono"
                    font.pixelSize: 96
                    font.weight: Font.Bold
                    renderType: Text.NativeRendering
                }

                Text {
                    text: ":"
                    color: Qt.alpha(root.foreColor, 0.6)
                    font.family: "JetBrainsMono"
                    font.pixelSize: 90
                    font.weight: Font.Light
                    renderType: Text.NativeRendering
                }

                Text {
                    text: root.minutes
                    color: root.foreColor
                    font.family: "JetBrainsMono"
                    font.pixelSize: 96
                    font.weight: Font.Bold
                    renderType: Text.NativeRendering
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(root.clock, "dddd").toUpperCase() + "  •  " + Qt.formatDate(root.clock, "dd MMM").toUpperCase()
                color: Qt.alpha(root.foreColor, 0.7)
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                font.letterSpacing: 2
            }
        }

        // 2. Interactive Switcher (Idle Hint vs Username + Input)
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 320
            implicitHeight: 90

            // Idle State Hint
            Text {
                id: hintText
                anchors.centerIn: parent
                text: "PRESS ANY KEY TO UNLOCK"
                color: Qt.alpha(root.foreColor, 0.4)
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.letterSpacing: 3
                font.bold: true

                opacity: root.authenticating ? 0 : 1
                scale: root.authenticating ? 0.92 : 1
                transformOrigin: Item.Center

                Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            }

            // Auth State Container (Username ON TOP of Input Box)
            ColumnLayout {
                id: authBlock
                anchors.centerIn: parent
                spacing: 12
                opacity: root.authenticating ? 1 : 0
                scale: root.authenticating ? 1 : 0.94
                transformOrigin: Item.Center

                Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

                // Username Display
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: "󰀉"
                        color: root.foreColor
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }

                    Text {
                        text: root.userName || "User"
                        color: root.foreColor
                        font.family: "JetBrainsMono"
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }
                }

                // Password Box Container
                Rectangle {
                    id: field
                    property bool shown: false

                    Layout.alignment: Qt.AlignHCenter
                    width: 260 // 🔥 FIX: Locked to 260px. No more ball shape.
                    height: 44
                    radius: 22
                    color: Qt.alpha("black", 0.5)
                    border.color: root.context.showFailure
                    ? root.failColor
                    : (passwordBox.activeFocus ? Qt.alpha(root.foreColor, 0.5) : Qt.alpha(root.foreColor, 0.15))
                    border.width: 0
                    clip: true

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Timer {
                        id: hideTimer
                        interval: 4000
                        repeat: false
                        onTriggered: {
                            if (passwordBox.text.length === 0 && !root.context.showFailure) {
                                field.shown = false
                            }
                        }
                    }

                    TextInput {
                        id: passwordBox
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18

                        focus: true
                        // 🔒 Block input while checking hash
                        enabled: !root.context.unlockInProgress

                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData

                        font.family: "JetBrainsMono"
                        font.pixelSize: 14
                        font.letterSpacing: 4
                        // 🔒 Hide typed dots while checking
                        color: root.context.unlockInProgress ? "transparent" : root.foreColor
                        selectionColor: root.failColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter

                        onTextChanged: {
                            root.context.currentText = passwordBox.text
                            field.shown = true
                            hideTimer.restart()
                        }

                        // 🔒 Instantly ask system to unlock
                        onAccepted: {
                            if (passwordBox.text.length > 0) {
                                root.context.tryUnlock()
                            }
                        }

                        Connections {
                            target: root.context
                            function onCurrentTextChanged() {
                                passwordBox.text = root.context.currentText
                            }
                        }
                    }

                    // Placeholders / Failure overlay
                    Item {
                        anchors.fill: parent
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            text: "Password..."
                            // 🔒 Hidden when checking hash
                            visible: !root.context.showFailure && !root.context.unlockInProgress && passwordBox.text.length === 0
                            color: Qt.alpha(root.foreColor, 0.35)
                            font.family: "JetBrainsMono"
                            font.pixelSize: 13
                            font.italic: true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "..."
                            // 🔒 Shown only when checking hash
                            visible: root.context.unlockInProgress
                            color: root.foreColor
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Incorrect password"
                            visible: root.context.showFailure
                            color: root.failColor
                            font.family: "JetBrainsMono"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }
                }
            }
        }
    }

    // // ---------- NOW PLAYING (Bottom-Right) ----------
    // Text {
    //     id: song
    //     anchors {
    //         right: parent.right
    //         bottom: parent.bottom
    //         rightMargin: 40
    //         bottomMargin: 40
    //     }
    //     text: root.songText
    //     color: Qt.alpha(root.foreColor, 0.8)
    //     font.family: "JetBrainsMono"
    //     font.pixelSize: 14
    //     font.italic: true
    //     horizontalAlignment: Text.AlignRight
    //     width: Math.min(song.implicitWidth, 450)
    //     wrapMode: Text.Wrap
    //     maximumLineCount: 2
    //     elide: Text.ElideRight
    //
    //     opacity: root.active ? 1.0 : 0.0
    //     transform: Translate {
    //         y: root.active ? 0 : 16
    //         Behavior on y {
    //             NumberAnimation { duration: 550; easing.type: Easing.OutCubic }
    //         }
    //     }
    //
    //     Behavior on opacity {
    //         NumberAnimation { duration: 400; easing.type: Easing.OutQuart }
    //     }
    // }
    //
    // Timer {
    //     interval: 1000
    //     running: true
    //     repeat: true
    //     onTriggered: songReader.running = true
    // }
    //
    // Process {
    //     id: songReader
    //     command: ["bash", "-c", "~/.config/hypr/scripts/songdetail.sh 2> /dev/null || true"]
    //
    //     stdout: StdioCollector {
    //         onTextChanged: {
    //             if (text.length > 0) root.songText = text.trim()
    //         }
    //     }
    // }
}
