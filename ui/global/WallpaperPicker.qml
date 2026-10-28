import QtQuick
import Quickshell
import Quickshell.Io
import "../../core/Shortcuts/"

Item {
    id: root
    anchors.fill: parent

    property var stateEngine
    property var themeEngine
    property var settings

    readonly property string home: Quickshell.env("HOME") || ""
    readonly property string wallpaperDir: settings ? settings.wallpaperDirectoryResolved : home + "/Pictures/wallpapers"
    readonly property real transitionDuration: settings ? settings.wallpaperTransition : 0.75
    readonly property string listScript: home + "/.config/quickshell/scripts/ListWallpapers.sh"
    readonly property string applyScript: home + "/.config/quickshell/scripts/ApplyWallpaper.sh"

    property var allFiles: []

    readonly property bool pickerOpen: stateEngine ? stateEngine.state === "wallpaper" : false

    Process {
        id: fetchWallpapers
        command: ["bash", root.listScript, root.wallpaperDir]

        stdout: StdioCollector {
            id: wallpaperCollector
        }

        onExited: {
            root.allFiles = wallpaperCollector.text.trim().split("\n").filter(f => f.length > 0)
            root.updateModel(root.allFiles)
        }
    }

    // One reusable process; the old code created a new Process via
    // Qt.createQmlObject() on every click and never destroyed it.
    Process {
        id: applyProc
    }

    WallpaperShortcuts {
        active: root.pickerOpen
        stateEngine: root.stateEngine
        onApplyRequested: (fileName) => root.applyWallpaper(fileName)
    }

    function updateModel(list) {
        wallpaperModel.clear()
        for (const file of list)
            wallpaperModel.append({ fileName: file })
    }

    function filterModel(query) {
        const filtered = root.allFiles.filter(file => file.toLowerCase().includes(query))
        updateModel(filtered)
    }

    function applyWallpaper(fileName) {
        if (!fileName || applyProc.running)
            return

        const fullPath = root.wallpaperDir + "/" + fileName
        applyProc.command = ["bash", root.applyScript, fullPath, String(root.transitionDuration)]
        applyProc.running = true

        if (root.themeEngine) {
            root.themeEngine.saveWallpaper(fullPath)
            root.themeEngine.setWallpaper(fullPath)
        }

        // Close immediately: the wallpaper transition has already started and
        // wallust updates the palette in the background.
        if (root.stateEngine)
            root.stateEngine.showClock()
    }

    Component.onCompleted: fetchWallpapers.running = true
    onWallpaperDirChanged: fetchWallpapers.running = true

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
            onTextChanged: root.filterModel(text.toLowerCase())
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
                clip: true

                Image {
                    anchors.fill: parent
                    source: "file://" + root.wallpaperDir + "/" + fileName
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
                    root.applyWallpaper(fileName)
                }
            }

            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuint } }
        }
    }
}
