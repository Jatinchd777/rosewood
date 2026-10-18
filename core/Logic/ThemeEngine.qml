import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: engine

    property color background: wallustColors.background
    property color on_background: wallustColors.on_background
    property color surface: wallustColors.surface
    property color surface_variant: wallustColors.surface_variant
    property color on_surface: wallustColors.on_surface
    property color on_surface_variant: wallustColors.on_surface_variant
    property color primary: wallustColors.primary
    property color on_primary: wallustColors.on_primary
    property color primary_container: wallustColors.primary_container
    property color on_primary_container: wallustColors.on_primary_container
    property color secondary: wallustColors.secondary
    property color on_secondary: wallustColors.on_secondary
    property color secondary_container: wallustColors.secondary_container
    property color on_secondary_container: wallustColors.on_secondary_container
    property color tertiary: wallustColors.tertiary
    property color on_tertiary: wallustColors.on_tertiary
    property color tertiary_container: wallustColors.tertiary_container
    property color on_tertiary_container: wallustColors.on_tertiary_container
    property color error: wallustColors.error
    property color on_error: wallustColors.on_error
    property color error_container: wallustColors.error_container
    property color on_error_container: wallustColors.on_error_container
    property color outline: wallustColors.outline
    property color shadow: wallustColors.shadow
    property color inverse_surface: wallustColors.inverse_surface
    property color inverse_on_surface: wallustColors.inverse_on_surface
    property color inverse_primary: wallustColors.inverse_primary
    property color surface_container: wallustColors.surface_container

    property string currentWallpaper: ""

    Component.onCompleted: {
        loadWallpaperFromFile()
    }

    Process {
        id: reader
        command: ["cat", "/home/lilarchie/.cache/wallpaper_state.txt"]

        stdout: StdioCollector {
            onTextChanged: {
                if (text.length > 0) {
                    engine.currentWallpaper = text.trim()
                }
            }
        }
    }

    function loadWallpaperFromFile() {
        reader.running = true
    }

    function setWallpaper(path) {
        currentWallpaper = path
    }

    function saveWallpaper(path) {
        let proc = Qt.createQmlObject('import Quickshell.Io; Process {}', engine)

        proc.command = [
        "sh", "-c",
        "printf '%s' \"" + path + "\" > ~/.cache/wallpaper_state.txt"
        ]

        proc.running = true
    }
}
