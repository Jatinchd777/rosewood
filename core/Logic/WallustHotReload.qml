import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    //property color background: "#101A18"
    property color background: "#080808"
    property color on_background: "#CCD6DC"
    property color surface: "#101A18"
    property color surface_variant: "#538585"
    property color on_surface: "#CCD6DC"
    property color on_surface_variant: "#CCD6DC"
    property color primary: "#B3C5CE"
    property color on_primary: "#3F7D79"
    property color primary_container: "#3F7D79"
    property color on_primary_container: "#AABEC8"
    property color secondary: "#B5C9D1"
    property color on_secondary: "#82969E"
    property color secondary_container: "#3F7D79"
    property color on_secondary_container: "#B5C9D1"
    property color tertiary: "#B3C5CE"
    property color on_tertiary: "#3F7D79"
    property color tertiary_container: "#AABEC8"
    property color on_tertiary_container: "#B5C9D1"
    property color error: "#ffb4a9"
    property color on_error: "#680003"
    property color error_container: "#930006"
    property color on_error_container: "#ffb4a9"
    property color outline: "#CCD6DC"
    property color shadow: "#000000"
    property color inverse_surface: "#1A1012"
    property color inverse_on_surface: "#DCD2CC"
    property color inverse_primary: "#CEBCB3"
    property color surface_container: "#ffffff"

    Component.onCompleted: reload()

    function reload() {
        reader.running = true
    }

    Process {
        id: reader
        command: ["cat", "/home/lilarchie/.config/quickshell/core/Logic/WallustColors.js"]

        stdout: SplitParser {
            onRead: (line) => {
                //let match = line.match(/^var\s+(\w+)\s*=\s*"(#[0-9a-fA-F]+)"\s*$/)
                let match = line.match(/^\s*var\s+(\w+)\s*=\s*"(#[0-9a-fA-F]{6})"\s*;?\s*$/)
                if (match) {
                    let name = match[1].replace(/([a-z])([A-Z])/g, "$1_$2").toLowerCase()
                    if (name in root) root[name] = match[2]
                }
            }
        }
    }
}
