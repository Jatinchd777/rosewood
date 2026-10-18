import QtQuick
import Quickshell

QtObject {
    id: root

    function powerOff(): void {
        Quickshell.execDetached(["systemctl", "poweroff"])
    }

    function reboot(): void {
        Quickshell.execDetached(["systemctl", "reboot"])
    }

    function suspend(): void {
        Quickshell.execDetached(["systemctl", "suspend"])
    }

    function lock(): void {
        Quickshell.execDetached(["bash","-c", "~/.config/quickshell/lockscreen/lock.sh"])
    }
}
