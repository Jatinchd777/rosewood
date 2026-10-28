import Quickshell
import "./core/Managers/"
import "./core/Logic/"
import "./ui/panels/"
import "./ui/global/"
ShellRoot {
    RosewoodSettings {
        id: settingsStore
    }
    PillState {
        id: pillState
        settings: settingsStore
    }
    AudioManager {
        id: audio;
        stateEngine: pillState
        windowRef: panelWindow
    }
    MainPanel {
        id: panelWindow
        stateEngine: pillState
        settings: settingsStore
    }
}
