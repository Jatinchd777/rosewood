// AppLauncher.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../core/Shortcuts/"
import "../../../ui/global/PillState.qml"
import "AppEngine.js" as AppEngine

Item {
    id: launcherRoot
    anchors.fill: parent
    implicitWidth: 560
    implicitHeight: 450

    property int absoluteGridWidth: width - 32
    signal requestClose()
    property var masterApps: []

    property color colorBg: theme.background
    property color colorBorder: "transparent"
    property color colorFg: theme.on_background
    property color colorAccent: theme.primary
    property color colorMuted: theme.on_surface_variant

    property bool isCalcMode: searchInput.text.startsWith("=")
    property bool isCmdMode: searchInput.text.startsWith(":")
    property string calcResult: ""

    LauncherShortcuts { }

    property var rawAppsList: []

    Process {
        id: appIndexer
        command: [
        "bash", "-c",
        "find /usr/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null | while read -r file; do " +
        "awk -F= '" +
        "/^NoDisplay=true/ {skip=1} " +
        "/^Name=/ && !n {n=$2} " +
        "/^Icon=/ && !i {i=$2} " +
        "/^Exec=/ && !e {gsub(/%[a-zA-Z]/, \"\"); e=$2} " +
        "END {if(n && e && !skip) { print n \"| \" e \"| \" (i?i:\"application-x-executable\") }}' \"$file\"; " +
        "done | sort -f"
        ]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                let appObj = AppEngine.parseAppLine(data);
                if (appObj) {
                    rawAppsList.push(appObj);
                    masterApps = rawAppsList;
                    appsModel.append(appObj);
                }
            }
        }
    }

    Process {
        id: appRunner
        command: []
        function launch(cmd) {
            if (!cmd) return;
            let cleanCmd = cmd.replace(/['"]/g, "").trim();
                command = ["hyprctl", "dispatch", 'hl.dsp.exec_cmd("' + cleanCmd + '")'];
                startDetached();
                searchInput.clear();
                launcherRoot.requestClose();
            }
                function executeRaw(cmd) {
                if (!cmd) return;
                command = ["bash", "-c", cmd];
                startDetached();
                searchInput.clear();
                launcherRoot.requestClose();
            }
            }

                function filterApps() {
                appsModel.clear();
                let query = searchInput.text.toLowerCase();
                let filtered = masterApps.filter(app => app.name.toLowerCase().includes(query));
                for (let i = 0; i < filtered.length; i++) {
                appsModel.append(filtered[i]);
            }
                if (appsGrid.count > 0) appsGrid.currentIndex = 0;
            }

                function restoreAllApps() {
                appsModel.clear();
                for (let i = 0; i < masterApps.length; i++) {
                appsModel.append(masterApps[i]);
            }
                if (appsGrid.count > 0) appsGrid.currentIndex = 0;
            }

                ListModel { id: appsModel }
                Component.onCompleted: searchInput.forceActiveFocus()

                onVisibleChanged: {
                if (visible) {
                searchInput.clear();
                restoreAllApps();
                searchInput.forceActiveFocus();
            }
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
                if (launcherRoot.isCalcMode) {
                launcherRoot.calcResult = AppEngine.calculate(text.substring(1));
            } else if (launcherRoot.isCmdMode) {
            } else {
                if (text.trim() === "") {
                launcherRoot.restoreAllApps();
            } else {
                filterApps();
            }
            }
            }

                Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (launcherRoot.isCmdMode) {
                appRunner.executeRaw(text.substring(1));
                event.accepted = true;
            } else if (!launcherRoot.isCalcMode && appsModel.count > 0) {
                let currentApp = appsModel.get(appsGrid.currentIndex);
                if (currentApp && currentApp.execCmd) {
                appRunner.launch(currentApp.execCmd);
            }
                event.accepted = true;
            }
            } else if (event.key === Qt.Key_Up) {
                appsGrid.moveCurrentIndexUp(); event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                appsGrid.moveCurrentIndexDown(); event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                appsGrid.moveCurrentIndexLeft(); event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                appsGrid.moveCurrentIndexRight(); event.accepted = true;
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
                Text { text: "Calculator"; font.family: "JetBrains Mono"; color: theme.tertiary; Layout.alignment: Qt.AlignHCenter }
                Text { text: launcherRoot.calcResult ? launcherRoot.calcResult : "0"; font.family: "JetBrains Mono"; font.pixelSize: 28; color: theme.on_background; Layout.alignment: Qt.AlignHCenter }
            }
            }

                Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                visible: launcherRoot.isCmdMode
                ColumnLayout {
                anchors.centerIn: parent
                Text { text: "Bash Mode"; font.family: "JetBrains Mono"; color: theme.error; Layout.alignment: Qt.AlignHCenter }
                Text { text: "Press Enter to run command raw"; font.family: "JetBrains Mono"; font.pixelSize: 14; color: theme.on_surface_variant; Layout.alignment: Qt.AlignHCenter }
            }
            }

                GridView {
                id: appsGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: appsModel
                clip: true
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                visible: !launcherRoot.isCalcMode && !launcherRoot.isCmdMode

                cellWidth: Math.floor(launcherRoot.absoluteGridWidth / 2)
                cellHeight: 52
                keyNavigationWraps: false
                flow: GridView.LeftToRight

                delegate: AppDelegate { }
            }
            }
            }
