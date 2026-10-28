import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property var theme
    property string title
    property string description
    property real from: 0
    property real to: 100
    property real stepSize: 1
    property real value: 0
    property int decimals: 0
    property string suffix: ""
    property string valueText: ""

    signal moved(real value)

    function stepped(v) {
        if (root.stepSize <= 0)
            return v
        const steps = Math.round((v - root.from) / root.stepSize)
        return Math.min(root.to, Math.max(root.from, root.from + steps * root.stepSize))
    }

    width: parent ? parent.width : 0
    height: layout.implicitHeight + 30
    radius: 10
    color: Qt.alpha(root.theme.surface, 0.4)
    border.width: 1
    border.color: Qt.alpha(root.theme.surface_variant, 0.35)

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.topMargin: 15
        height: implicitHeight
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.theme.on_background
                font.family: "JetBrains Mono"
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Text {
                text: root.valueText !== ""
                    ? root.valueText
                    : Number(root.value).toFixed(root.decimals) + root.suffix
                color: root.theme.primary
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.description
            color: root.theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: 11
            lineHeight: 1.2
            wrapMode: Text.WordWrap
        }

        Slider {
            id: slider

            Layout.fillWidth: true
            Layout.topMargin: 4
            topPadding: 8
            bottomPadding: 8
            from: root.from
            to: root.to
            stepSize: root.stepSize
            snapMode: Slider.SnapAlways
            value: root.value

            onMoved: root.moved(root.stepped(value))

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 5
                radius: 3
                color: Qt.alpha(root.theme.surface_variant, 0.4)

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 3
                    color: root.theme.primary
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: root.theme.on_primary
                border.width: 2
                border.color: root.theme.primary
            }
        }
    }
}
