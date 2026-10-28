import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../core/Shortcuts/"
import "../global/PillState.qml"
import "../../core/Logic/"

Item {
    id: root
    implicitWidth: 550
    implicitHeight: 400

    anchors.fill: parent

    property var stateEngine

    ListModel {
        id: clipboardModel
    }

    property color accent: theme.primary

    Component.onCompleted: {
        clipboardFetcher.running = true;
    }

    ClipboardShortcuts {
        active: root.visible
        stateEngine: root.stateEngine
    }

    function appendClipboard(newText, isImg) {
        if (newText === "") return;
        if (clipboardModel.count > 0 && clipboardModel.get(0).clipText === newText) return;

        clipboardModel.insert(0, {
                "clipText": newText,
                "isImage": isImg
        });

        if (clipboardModel.count > 20) {
            clipboardModel.remove(20)
        }
    }

    function clearSystemClipboard() {
        clipboardModel.clear();
        clipboardClearer.running = true;
    }

    property string pendingText: ""

    Timer {
        id: clipboardDebounceTimer
        interval: 50
        repeat: false
        onTriggered: {
            let text = root.pendingText;
            if (text.startsWith("[[IMG]]")) {
                appendClipboard(text.substring(7).trim(), true);
            } else {
                appendClipboard(text.trim(), false);
            }
            root.pendingText = "";
        }
    }

    Process {
        id: clipboardWatcher
        command: ["wl-paste", "--watch", "echo", "NEW_CLIP"]
        running: true
        onExited: running = true
        stdout: SplitParser {
            onRead: {
                clipboardFetcher.running = true;
            }
        }
    }

    Process {
        id: clipboardFetcher
        command: ["bash", "-c", "if wl-paste -l | grep -q '^image/'; then f=\"/tmp/qs_clip_$(date +%s%N).png\"; wl-paste -t image/png > \"$f\"; echo \"[[IMG]]$f\"; else wl-paste; fi"]
        stdout: SplitParser {
            onRead: (data) => {
                handleIncomingLine(data);
            }
        }
    }

    function copySelectedToSystem(index) {
        let item = clipboardModel.get(index);
        if (item.isImage) {
            clipboardCopier.command = ["bash", "-c", "wl-copy -t image/png < " + item.clipText];
        } else {
            clipboardCopier.command = ["wl-copy", item.clipText];
        }
        clipboardCopier.running = true;
    }

    function handleIncomingLine(line) {
        if (root.pendingText === "") {
            root.pendingText = line;
        } else {
            root.pendingText += "\n" + line;
        }
        clipboardDebounceTimer.restart();
    }

    Process {
        id: clipboardClearer
        command: ["wl-copy", "-c"]
    }

    Process {
        id: clipboardChecker
        command: ["wl-paste", "-n"]
        property string targetText: ""
        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() === clipboardChecker.targetText) {
                    clipboardClearer.running = true;
                }
            }
        }
    }

    Process {
        id: clipboardCopier
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }
            Text {
                text: "󰎟 Clear History"
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 12
                color: clipboardModel.count > 0 ? theme.on_surface : theme.on_surface_variant

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        clearSystemClipboard();
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                visible: clipboardModel.count === 0
                spacing: 8

                Text {
                    text: "󰅍"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 32
                    color: theme.surface_variant
                    Layout.alignment: Qt.AlignCenter
                }
                Text {
                    text: "Clipboard is empty."
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    color: theme.on_surface_variant
                    Layout.alignment: Qt.AlignCenter
                }

                Behavior on height {
                    NumberAnimation {
                        duration:350
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration:0
                        easing.type: Easing.OutQuint
                    }
                }
            }

            ListView {
                id: clipboardListView
                anchors.fill: parent
                model: clipboardModel
                spacing: 8
                clip: true
                visible: clipboardModel.count > 0

                delegate: Rectangle {
                    id: clipCard
                    width: clipboardListView.width
                    height: model.isImage ? 80 : 55

                    color: cardMouseArea.containsMouse ? Qt.alpha(theme.surface_variant, 0.4) : Qt.alpha(theme.surface, 0.4)

                    radius: 6
                    border.color: Qt.alpha(theme.surface_variant, 0.4)
                    border.width: 1
                    clip: true

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutSine }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration:350
                            easing.type: Easing.OutQuint
                        }
                    }

                    MouseArea {
                        id: cardMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            clipboardListView.currentIndex = index;
                            copySelectedToSystem(index);
                            if (root.stateEngine)
                                root.stateEngine.showClock();
                        }
                    }

                    RowLayout {
                        id: cardLayout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Rectangle {
                            width: 4
                            Layout.fillHeight: true
                            radius: 2
                            color: accent
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Image {
                                visible: model.isImage
                                source: model.isImage ? "file://" + model.clipText : ""
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                height: 60
                                sourceSize.height: 60
                                fillMode: Image.PreserveAspectFit
                                horizontalAlignment: Image.AlignLeft
                                asynchronous: true
                            }

                            Text {
                                visible: !model.isImage
                                text: model.clipText
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                color: theme.on_background
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                wrapMode: Text.WrapAnywhere
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            text: "󰅖"
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 14
                            color: theme.on_surface_variant
                            Layout.alignment: Qt.AlignVCenter

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!model.isImage) {
                                        clipboardChecker.targetText = model.clipText;
                                        clipboardChecker.running = true;
                                    }
                                    clipboardModel.remove(index);
                                }
                                onEntered: parent.color = theme.on_background
                                onExited: parent.color = theme.on_surface_variant
                            }
                        }
                    }
                }
            }
        }
    }
}
