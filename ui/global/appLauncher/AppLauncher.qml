// AppLauncher.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../core/Shortcuts/"
import "AppEngine.js" as AppEngine

Item {
    id: launcherRoot
    anchors.fill: parent
    implicitWidth: 560
    implicitHeight: 450

    property int absoluteGridWidth: width - 32
    property int columns: 2
    property var stateEngine
    signal requestClose()

    property color colorBg: theme.background
    property color colorBorder: "transparent"
    property color colorFg: theme.on_background
    property color colorAccent: theme.primary
    property color colorMuted: theme.on_surface_variant

    property bool isCalcMode: searchInput.text.startsWith("=")
    property bool isCmdMode: searchInput.text.startsWith(":")
    property string calcResult: ""

    readonly property string query: searchInput.text
    readonly property bool searchHasFocus: searchInput.activeFocus
    readonly property int appCount: filteredApps.length
    readonly property bool isCurrentItemValid: appsGrid.currentIndex >= 0 && appsGrid.currentIndex < filteredApps.length

    // DesktopEntries.applications is Quickshell's built-in desktop entry index.
    // It only contains visible applications (no Hidden/NoDisplay entries), so
    // there is no need to parse .desktop files ourselves.
    readonly property var filteredApps: {
        const needle = launcherRoot.query.trim().toLowerCase()

        // Entries without an Exec command cannot be launched by
        // DesktopEntry.execute() (for example DBusActivatable-only entries).
        const apps = DesktopEntries.applications.values.filter(app => {
            if (app.command.length === 0)
                return false
            return needle === "" || app.name.toLowerCase().includes(needle)
        })

        apps.sort((a, b) => {
            const aName = a.name.toLowerCase()
            const bName = b.name.toLowerCase()
            return aName < bName ? -1 : (aName > bName ? 1 : 0)
        })

        return apps
    }

    LauncherShortcuts {
        stateEngine: launcherRoot.stateEngine
        launcher: launcherRoot
    }

    function launch(entry) {
        if (!entry)
            return
        entry.execute()
        searchInput.clear()
        launcherRoot.requestClose()
    }

    function launchCurrent() {
        if (launcherRoot.isCalcMode || launcherRoot.isCmdMode)
            return
        if (!launcherRoot.isCurrentItemValid)
            return
        launcherRoot.launch(launcherRoot.filteredApps[appsGrid.currentIndex])
    }

    function executeRaw(cmd) {
        if (!cmd)
            return
        Quickshell.execDetached(["bash", "-c", cmd])
        searchInput.clear()
        launcherRoot.requestClose()
    }

    function selectUp() { appsGrid.moveCurrentIndexUp() }
    function selectDown() { appsGrid.moveCurrentIndexDown() }
    function selectLeft() { appsGrid.moveCurrentIndexLeft() }
    function selectRight() { appsGrid.moveCurrentIndexRight() }

    function focusSearch() {
        searchInput.forceActiveFocus()
    }

    function clearSearch() {
        searchInput.clear()
    }

    function prepare() {
        searchInput.clear()
        appsGrid.currentIndex = launcherRoot.appCount > 0 ? 0 : -1
        searchInput.forceActiveFocus()
    }

    onVisibleChanged: {
        if (visible)
            prepare()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        Rectangle {
            id: searchBar
            width: 400
            Layout.alignment: Qt.AlignHCenter
            height: 40
            color: Qt.alpha(theme.surface, 0.4)
            radius: 10
            border.color: isCalcMode ? theme.tertiary : (isCmdMode ? theme.error : (searchInput.activeFocus ? colorAccent : Qt.alpha(theme.surface, 0.4)))
            border.width: 1

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.margins: 10
                color: theme.on_background
                font.pixelSize: 14
                font.family: "JetBrains Mono"
                verticalAlignment: TextInput.AlignVCenter
                focus: true

                onTextChanged: {
                    // Check the text directly instead of isCalcMode/isCmdMode:
                    // those bindings update after this handler, so pasting a
                    // full expression like "=2+3" would otherwise be missed.
                    if (text.startsWith("=")) {
                        launcherRoot.calcResult = AppEngine.calculate(text.substring(1))
                    } else if (text.startsWith(":")) {
                        launcherRoot.calcResult = ""
                    } else {
                        appsGrid.currentIndex = launcherRoot.appCount > 0 ? 0 : -1
                    }
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (launcherRoot.isCmdMode) {
                            launcherRoot.executeRaw(text.substring(1))
                            event.accepted = true
                        } else if (!launcherRoot.isCalcMode) {
                            launcherRoot.launchCurrent()
                            event.accepted = true
                        }
                    } else if (event.key === Qt.Key_Up) {
                        launcherRoot.selectUp()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        launcherRoot.selectDown()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Left) {
                        launcherRoot.selectLeft()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Right) {
                        launcherRoot.selectRight()
                        event.accepted = true
                    }
                }

                Text {
                    text: "Search apps..."
                    color: colorMuted
                    font.pixelSize: 14
                    font.family: "JetBrains Mono"
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    visible: searchInput.text.length === 0 && !searchInput.activeFocus
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            visible: launcherRoot.isCalcMode
            ColumnLayout {
                anchors.centerIn: parent
                Text {
                    text: "Calculator"
                    font.family: "JetBrains Mono"
                    color: theme.tertiary
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: launcherRoot.calcResult ? launcherRoot.calcResult : "0"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 28
                    color: theme.on_background
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            visible: launcherRoot.isCmdMode
            ColumnLayout {
                anchors.centerIn: parent
                Text {
                    text: "Bash Mode"
                    font.family: "JetBrains Mono"
                    color: theme.error
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Press Enter to run command raw"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    color: theme.on_surface_variant
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        GridView {
            id: appsGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: launcherRoot.filteredApps
            clip: true
            currentIndex: 0
            boundsBehavior: Flickable.StopAtBounds
            visible: !launcherRoot.isCalcMode && !launcherRoot.isCmdMode

            cellWidth: Math.floor(launcherRoot.absoluteGridWidth / Math.max(1, launcherRoot.columns))
            cellHeight: 52
            keyNavigationWraps: false
            flow: GridView.LeftToRight

            delegate: AppDelegate { }
        }
    }
}
