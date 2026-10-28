import QtQuick

Text {
    id: root

    property var theme

    topPadding: 10
    bottomPadding: 2
    color: root.theme.primary
    font.family: "JetBrains Mono"
    font.pixelSize: 10
    font.weight: Font.Bold
    font.letterSpacing: 1.8
}
