import Quickshell
import "./core/Managers/"
import "./core/Logic/"
import "./ui/panels/"
import "./ui/global/"
ShellRoot {
    PillState {
        id: pillState
    }
    AudioManager {
        id: audio;
        stateEngine: pillState
        windowRef: panelWindow
    }
    MainPanel {
        id: panelWindow
        stateEngine: pillState
    }
}
