import QtQuick
import Quickshell.Io
import "../../core/Shortcuts/"

Item {
    id: root
    anchors.fill: parent

    property var allFiles: []

    Process {
        id: fetchWallpapers
        command: ["bash", "-c", "/home/lilarchie/.config/quickshell/scripts/ListWallpapers.sh"]
        stdout: StdioCollector {
            id: wallpaperCollector
            onTextChanged: {
                allFiles = text.trim().split("\n").filter(f => f.length > 0)
                updateModel(allFiles)
            }
        }
    }

    WallpaperShortcuts {}

    function updateModel(list) {
        wallpaperModel.clear()
        for (let file of list) {
            wallpaperModel.append({ fileName: file })
        }
    }

    function filterModel(query) {
        let filtered = allFiles.filter(file => file.toLowerCase().includes(query))
        updateModel(filtered)
    }

    Component.onCompleted: fetchWallpapers.running = true
    ListModel { id: wallpaperModel }

    Rectangle {
        id: searchBar
        width: parent.width - 300
        height: 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        color: Qt.alpha(theme.surface, 0.4)
        radius: 10
        border.color: Qt.alpha(theme.surface_variant, 0.4)
        focus: true
        border.width: 1

        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.margins: 10
            color: theme.on_background
            font.pixelSize: 14
            verticalAlignment: TextInput.AlignVCenter

            Text {
                text: "Search wallpapers..."
                color: theme.on_surface_variant
                font.pixelSize: 14
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: searchInput.text.length === 0 && !searchInput.activeFocus
            }
            onTextChanged: filterModel(text.toLowerCase())
        }
    }

    GridView {
        id: grid
        focus: true
        anchors.top: searchBar.bottom
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        maximumFlickVelocity: 2500
        flickDeceleration: 1500
        cacheBuffer: 1500
        highlightMoveDuration: 250

        cellWidth: width / 4
        cellHeight: 140
        clip: true
        model: wallpaperModel

        delegate: Rectangle {
            id: container
            width: grid.cellWidth - 1
            height: 137
            color: "transparent"
            border.color: mouseArea.containsMouse ? theme.primary : "transparent"
            border.width: 2
            clip: true

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                color: "transparent"
                radius: 12
                clip:true

                Image {
                    anchors.fill: parent
                    source: "file:///home/lilarchie/Pictures/wallpapers/" + fileName
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: 220
                    sourceSize.height: 125
                    clip: true
                }
            }

            Timer {
                id: resetScaleTimer
                interval: 250
                onTriggered: container.scale = 1.0
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    container.scale = 0.95
                    resetScaleTimer.start()
                    let fullPath = "/home/lilarchie/Pictures/wallpapers/" + fileName
                    let applyProc = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
                    applyProc.command = ["/home/lilarchie/.config/quickshell/scripts/ApplyWallpaper.sh", fullPath];
                    applyProc.running = true;
                    theme.saveWallpaper(fullPath)
                    theme.setWallpaper(fullPath);
                }
            }

            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuint } }
        }
    }
}
