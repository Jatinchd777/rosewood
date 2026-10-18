import QtQuick

Row {
    id: navBar
    property int activeTab: 0
    signal tabChanged(int tab)

    anchors.top: parent.top
    anchors.topMargin: 12
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 25

    property color accent: theme.primary

    component NavButton: Item {
        property string icon
        property int tabIndex
        width: 32; height: 32

        Text {
            text: parent.icon
            font.pixelSize: 15
            font.family: "JetBrains Mono Nerd Font Propo"
            color: activeTab === parent.tabIndex ? navBar.accent : theme.primary_container
            anchors.centerIn: parent
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: tabChanged(parent.tabIndex)
        }
    }

    NavButton { icon: "󰕮"; tabIndex: 0 }
    NavButton { icon: "󰎆"; tabIndex: 1 }
    NavButton { icon: ""; tabIndex: 2 }
    NavButton { icon: ""; tabIndex: 3 }
}
