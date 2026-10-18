import QtQuick
import Quickshell.Io

Item {
    id: root

    property var stateEngine

    property real currentBrightness: 0.0
    property bool bootGuard: false

    Process {
        id: bProc
        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            id: bCollector
            onTextChanged: {
                let trimmed = text.trim();
                if (!trimmed) return;
                let parts = trimmed.split(",");
                if (parts.length >= 4) {
                    let pct = parseFloat(parts[3]);
                    if (!isNaN(pct)) {
                        let newBrightness = pct / 100;

                        if (root.currentBrightness !== newBrightness) {
                            root.currentBrightness = newBrightness;

                            if (root.bootGuard && root.stateEngine) {
                                root.stateEngine.showBrightness();
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            bProc.running = false
            bProc.running = true
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: root.bootGuard = true
    }

    Process { id: bSetProc }

    function setBrightness(percent: real) {
        bSetProc.exec(["brightnessctl", "set", Math.round(percent * 100) + "%"])
    }
}
