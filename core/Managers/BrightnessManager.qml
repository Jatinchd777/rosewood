import QtQuick
import Quickshell.Io

Item {
    id: root

    property var stateEngine

    property real currentBrightness: 0.0
    property bool bootGuard: false

    property string brightnessPath: ""
    property string maxBrightnessPath: ""
    property int maxBrightness: 0

    property real pendingBrightness: 0.0
    property real appliedBrightness: -1

    function updateFromFile() {
        const raw = parseInt(brightnessFile.text())
        if (isNaN(raw) || root.maxBrightness <= 0)
            return

        const value = Math.max(0, Math.min(1, raw / root.maxBrightness))
        if (root.currentBrightness === value)
            return

        root.currentBrightness = value
        if (root.bootGuard && root.stateEngine)
            root.stateEngine.showBrightness()
    }

    // Discover the backlight device once instead of polling brightnessctl
    // ten times a second. Subsequent changes arrive through inotify.
    Process {
        id: discover
        running: true
        command: [
            "sh", "-c",
            "for f in /sys/class/backlight/*/brightness; do [ -e \"$f\" ] && { printf '%s' \"$f\"; break; }; done"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim()
                if (path.length === 0)
                    return

                root.brightnessPath = path
                root.maxBrightnessPath = path.replace(/brightness$/, "max_brightness")
            }
        }
    }

    FileView {
        id: maxFile
        path: root.maxBrightnessPath
        printErrors: false
        onTextChanged: {
            const value = parseInt(maxFile.text())
            if (!isNaN(value) && value > 0) {
                root.maxBrightness = value
                root.updateFromFile()
            }
        }
    }

    FileView {
        id: brightnessFile
        path: root.brightnessPath
        printErrors: false
        watchChanges: true
        onFileChanged: brightnessFile.reload()
        onTextChanged: root.updateFromFile()
    }

    Timer {
        interval: 1200
        running: true
        onTriggered: root.bootGuard = true
    }

    Process { id: bSetProc }

    // Throttle writes while the slider is being dragged. The first change is
    // applied immediately, then at most once per 60 ms.
    Timer {
        id: applyTimer
        interval: 60
        repeat: true
        running: false
        onTriggered: {
            if (Math.abs(root.pendingBrightness - root.appliedBrightness) < 0.005) {
                applyTimer.running = false
                return
            }

            root.appliedBrightness = root.pendingBrightness
            bSetProc.exec(["brightnessctl", "set", Math.max(1, Math.round(root.pendingBrightness * 100)) + "%"])
        }
    }

    function setBrightness(percent: real) {
        root.pendingBrightness = Math.max(0, Math.min(1, percent))

        if (!applyTimer.running) {
            root.appliedBrightness = root.pendingBrightness
            bSetProc.exec(["brightnessctl", "set", Math.max(1, Math.round(root.pendingBrightness * 100)) + "%"])
            applyTimer.start()
        }
    }
}
