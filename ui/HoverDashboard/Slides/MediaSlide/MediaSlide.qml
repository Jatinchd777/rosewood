import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: mediaSlide
    anchors.fill: parent
    z: -1

    property bool isOpen: false

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutQuad
        }
    }

    property int playerIndex: 0
    property var playerList: Mpris.players.values
    property var activePlayer: playerList.length > 0 ? playerList[playerIndex % playerList.length] : null

    property color accent: theme.primary
    property string artUrl: activePlayer?.trackArtUrl ?? ""

    function formatTime(sec) {
        if (!sec || sec <= 0) return "0:00";
        let totalSeconds = Math.floor(sec);
        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
    }

    function calculateProgress(player) {
        if (!player) return 0;
        let trackWidth = progressBarTrack.width > 0 ? progressBarTrack.width : 200;
        let len = player.length ?? 0;
        if (len <= 0) return 0;
        let ratio = Math.min(Math.max(player.position / len, 0), 1);
        return ratio * trackWidth;
    }

    Timer {
        interval: 250
        running: mediaSlide.isOpen && mediaSlide.visible && playerList.length > 0
        repeat: true
        onTriggered: {
            let p = playerList.length > 0 ? playerList[playerIndex % playerList.length] : null;
            if (p) {
                progressBarFill.width = calculateProgress(p);
                elapsedTimeText.text = formatTime(p.position);
                totalTimeText.text = formatTime(p.length);
            } else {
                progressBarFill.width = 0;
                elapsedTimeText.text = "0:00";
                totalTimeText.text = "0:00";
            }
        }
    }

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 15
        }
        spacing: 20

        Text {
            text: "󰄽"
            font { family: "JetBrains Mono Nerd Font Propo"; pixelSize: 16 }
            color: playerList.length > 1 ? theme.on_surface_variant : "transparent"
            anchors.verticalCenter: parent.verticalCenter
            scale: leftHover.containsMouse ? 1.25 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

            MouseArea {
                id: leftHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (playerList.length <= 1) return;
                    playerIndex = (playerIndex - 1 + playerList.length) % playerList.length;
                }
            }
        }

        Row {
            spacing: 80
            anchors.verticalCenter: parent.verticalCenter

            Item {
                id: coverContainer
                width: 170; height: 190
                clip: false

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: (wheel) => {
                        let p = activePlayer;
                        if (!p || !p.volumeSupported) return;
                        let delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                        p.volume = Math.max(0, Math.min(1, p.volume + delta));
                        volIndicator.opacity = 1;
                        volTimer.restart();
                    }
                }

                Text {
                    id: volIndicator
                    anchors.centerIn: parent
                    text: Math.round((activePlayer?.volume ?? 0) * 100) + "%"
                    color: theme.on_surface
                    font { family: "JetBrains Mono"; pixelSize: 16; bold: true }
                    opacity: 0
                    z: 10
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Timer {
                    id: volTimer
                    interval: 800
                    onTriggered: volIndicator.opacity = 0
                }

                Image {
                    id: blurSource
                    width: 300; height: 260
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: -10
                    source: playerList.length > 0 ? playerList[playerIndex % playerList.length].trackArtUrl : ""
                    sourceSize.width: 300
                    sourceSize.height: 260
                    fillMode: Image.PreserveAspectFit
                    visible: false
                    asynchronous: true
                }

                MultiEffect {
                    source: blurSource
                    anchors.fill: blurSource
                    blurEnabled: true
                    blurMultiplier: 1.5
                    blur: 1.7
                    saturation: 0.8
                    z: -2
                }

                MultiEffect {
                    source: sharpCover
                    anchors.fill: sharpCover
                    shadowEnabled: true
                    shadowColor: theme.shadow
                    shadowBlur: 0.5
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 8
                    z: -1
                }

                Rectangle {
                    id: sharpCover
                    width: 170; height: 170
                    anchors.centerIn: parent
                    radius: 10
                    color: theme.surface_variant
                    clip: true

                    Image {
                        id: coverArt
                        anchors.fill: parent
                        source: playerList.length > 0 ? playerList[playerIndex % playerList.length].trackArtUrl : ""
                        sourceSize.width: 170
                        sourceSize.height: 170
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰎆"
                        font { family: "JetBrains Mono Nerd Font Propo"; pixelSize: 48 }
                        color: theme.outline
                        visible: playerList.length === 0 || !playerList[playerIndex % playerList.length].trackArtUrl
                    }
                }
            }

            Column {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 210

                Text {
                    text: playerList.length > 0 ? playerList[playerIndex % playerList.length].identity : ""
                    color: theme.on_surface_variant
                    font { family: "JetBrains Mono"; pixelSize: 9 }
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    opacity: playerList.length > 0 ? 0.9 : 0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                Item {
                    width: parent.width
                    height: 20
                    clip: true

                    Text {
                        id: titleText
                        text: playerList.length > 0 ? playerList[playerIndex % playerList.length].trackTitle : "No media"
                        color: theme.on_surface_variant
                        font { family: "JetBrains Mono"; pixelSize: 14; bold: true }
                        x: 0

                        Component.onCompleted: centerX()
                        onTextChanged: centerX()

                        function centerX() {
                            if (text.length < 25 || !marqueeAnim.running) {
                                x = Math.max(0, (parent.width - implicitWidth) / 2);
                            }
                        }

                        SequentialAnimation on x {
                            id: marqueeAnim
                            running: mediaSlide.isOpen && mediaSlide.visible && titleText.text.length >= 25 && playerList.length > 0 && playerList[playerIndex % playerList.length].isPlaying
                            loops: Animation.Infinite
                            onRunningChanged: {
                                if (!running) {
                                    titleText.x = Math.max(0, (titleText.parent.width - titleText.implicitWidth) / 2);
                                }
                            }

                            NumberAnimation {
                                from: titleText.x
                                to: -titleText.implicitWidth + titleText.parent.width - 10
                                duration: Math.max(3000, (titleText.implicitWidth - titleText.parent.width) * 40)
                                easing.type: Easing.Linear
                            }
                            PauseAnimation { duration: 1200 }
                            NumberAnimation {
                                from: -titleText.implicitWidth + titleText.parent.width - 10
                                to: 0
                                duration: 600
                                easing.type: Easing.InOutQuad
                            }
                            PauseAnimation { duration: 800 }
                        }
                    }
                }

                Text {
                    text: playerList.length > 0 ? playerList[playerIndex % playerList.length].trackArtist : "Unknown"
                    color: theme.on_surface_variant
                    font { family: "JetBrains Mono"; pixelSize: 11 }
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                Item {
                    width: parent.width
                    height: elapsedTimeText.height
                    Text {
                        id: elapsedTimeText
                        anchors.left: parent.left
                        text: formatTime(playerList.length > 0 ? playerList[playerIndex % playerList.length].position : 0)
                        color: theme.on_surface_variant
                        font { family: "JetBrains Mono"; pixelSize: 9 }
                    }
                    Text {
                        id: totalTimeText
                        anchors.right: parent.right
                        text: formatTime(playerList.length > 0 ? playerList[playerIndex % playerList.length].length : 0)
                        color: theme.on_surface_variant
                        font { family: "JetBrains Mono"; pixelSize: 9 }
                    }
                }

                Item {
                    width: parent.width
                    height: 5

                    Rectangle {
                        id: progressBarTrack
                        anchors.fill: parent
                        color: theme.primary_container
                        radius: 2.5

                        Rectangle {
                            id: progressBarFill
                            height: parent.height
                            width: 0
                            color: accent
                            radius: 2.5
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            let p = playerList[playerIndex % playerList.length];
                            if (p && p.canSeek && p.positionSupported && p.length > 0) {
                                p.position = (mouse.x / progressBarTrack.width) * p.length;
                            }
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 24

                    Text {
                        text: "󰒝"
                        font { family: "JetBrains Mono Nerd Font Propo"; pixelSize: 12 }
                        color: {
                            let p = playerList.length > 0 ? playerList[playerIndex % playerList.length] : null;
                            return (p && p.shuffle) ? accent : theme.on_surface_variant;
                        }
                        opacity: {
                            let p = playerList.length > 0 ? playerList[playerIndex % playerList.length] : null;
                            return (p && p.shuffleSupported) ? 1 : 0.3;
                        }
                        scale: shuffleHover.containsMouse ? 1.25 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                        MouseArea {
                            id: shuffleHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let p = playerList[playerIndex % playerList.length];
                                if (p && p.shuffleSupported) p.shuffle = !p.shuffle;
                            }
                        }
                    }

                    Text {
                        text: {
                            let p = playerList.length > 0 ? playerList[playerIndex % playerList.length] : null;
                            if (!p) return "󰑗";
                            return p.loopStatus === Mpris.LoopTrack ? "󰑘" :
                            p.loopStatus === Mpris.LoopPlaylist ? "󰑖" : "󰑗";
                        }
                        font { family: "JetBrains Mono Nerd Font Propo"; pixelSize: 12 }
                        color: {
                            let p = playerList.length > 0 ? playerList[playerIndex % playerList.length] : null;
                            return (p && p.loopStatus !== Mpris.LoopNone) ? accent : theme.on_surface_variant;
                        }
                        opacity: {
                            let p = playerList.length > 0 ? playerList[playerIndex % playerList.length] : null;
                            return (p && p.loopStatusSupported) ? 1 : 0.3;
                        }
                        scale: loopHover.containsMouse ? 1.25 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                        MouseArea {
                            id: loopHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let p = playerList[playerIndex % playerList.length];
                                if (!p || !p.loopStatusSupported) return;
                                let next = Mpris.LoopNone;
                                if (p.loopStatus === Mpris.LoopNone) next = Mpris.LoopPlaylist;
                                else if (p.loopStatus === Mpris.LoopPlaylist) next = Mpris.LoopTrack;
                                p.loopStatus = next;
                            }
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 40

                    Text {
                        text: "󰒮"
                        font { family: "JetBrains Mono Nerd Font Propo"; pixelSize: 18 }
                        color: theme.on_surface
                        scale: prevHover.containsMouse ? 1.25 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                        MouseArea {
                            id: prevHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let p = playerList[playerIndex % playerList.length];
                                if (p) p.previous();
                            }
                        }
                    }

                    Text {
                        text: {
                            let p = playerList.length > 0 ? playerList[playerIndex % playerList.length] : null;
                            return p?.isPlaying ? "󰏤" : "󰐊";
                        }
                        font { family: "JetBrains Mono Nerd Font Propo"; pixelSize: 18 }
                        color: theme.on_surface
                        scale: playHover.containsMouse ? 1.2 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                        MouseArea {
                            id: playHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let p = playerList[playerIndex % playerList.length];
                                if (p) p.togglePlaying();
                            }
                        }
                    }

                    Text {
                        text: "󰒭"
                        font { family: "JetBrains Mono Nerd Font Propo"; pixelSize: 18 }
                        color: theme.on_surface
                        scale: nextHover.containsMouse ? 1.25 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                        MouseArea {
                            id: nextHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let p = playerList[playerIndex % playerList.length];
                                if (p) p.next();
                            }
                        }
                    }
                }
            }
        }

        Text {
            text: "󰄾"
            font { family: "JetBrains Mono Nerd Font Propo"; pixelSize: 16 }
            color: playerList.length > 1 ? theme.on_surface_variant : "transparent"
            anchors.verticalCenter: parent.verticalCenter
            scale: rightHover.containsMouse ? 1.25 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

            MouseArea {
                id: rightHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (playerList.length <= 1) return;
                    playerIndex = (playerIndex + 1) % playerList.length;
                }
            }
        }
    }
}
