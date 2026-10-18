// modules/PowerManager.qml
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: pm

    property bool visible: false
    IpcHandler {
        target: "powerMenu"
        function toggle() { pm.visible = !pm.visible }
    }

    function powerOff() { Quickshell.exec(["systemctl", "poweroff"]) }
    function reboot() { Quickshell.exec(["systemctl", "reboot"]) }
    function suspend() { Quickshell.exec(["systemctl", "suspend"]) }
    function logout() { Quickshell.exec(["hyprctl", "dispatch", "exit"]) }
    function lock() { Quickshell.exec(["hyprlock"]) }
}
