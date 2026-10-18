import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth

Item {
    id: root
    anchors.fill: parent

    signal requestClose()

    property color accent: theme.primary
    property color cardColor: Qt.alpha(theme.surface, 0.4)
    property color borderColor: Qt.alpha(theme.surface_variant, 0.4)
    property color textMuted: theme.on_surface_variant

    property bool isPowered: Bluetooth.defaultAdapter?.enabled ?? false

    function handleDeviceClick(device) {
        if (!device) return

        if (device.connected) {
            device.disconnect()
        } else {
            device.connect()
        }
    }

    QtObject {
        id: backend

        property var deviceList: Bluetooth.devices.values

        function icon(connected) {
            return "󰂯"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            Text {
                text: "󰁍 Back"
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 12
                color: theme.on_surface

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.requestClose()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8
                visible: !root.isPowered

                Text {
                    text: "󰂲"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 34
                    color: theme.error
                    Layout.alignment: Qt.AlignCenter
                }
                Text {
                    text: "Bluetooth Disabled"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    color: theme.on_surface_variant
                    Layout.alignment: Qt.AlignCenter
                }
                Text {
                    text: "Enable Bluetooth or scan again."
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    color: theme.on_surface_variant
                    Layout.alignment: Qt.AlignCenter
                }
            }

            Item {
                anchors.fill: parent
                visible: root.isPowered

                Rectangle {
                    id: refreshButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: 120
                    height: 20
                    radius: 17
                    color: "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            console.log("Initiating Discovery Mode Scan...")
                            if (typeof Bluetooth.startScan === "function") {
                                Bluetooth.startScan()
                            }
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰑐"
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 13
                            color: accent
                        }
                        Text {
                            text: "Refresh"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            color: theme.on_surface
                            font.bold: true
                        }
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: backend.deviceList.length === 0

                    Text {
                        text: "󰂎"
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 34
                        color: theme.surface_variant
                        Layout.alignment: Qt.AlignCenter
                    }
                    Text {
                        text: "No Bluetooth Devices"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        color: theme.on_surface_variant
                        Layout.alignment: Qt.AlignCenter
                    }
                }

                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.bottomMargin: 35
                    visible: backend.deviceList.length > 0
                    spacing: 8
                    clip: true
                    model: backend.deviceList

                    delegate: Rectangle {
                        id: card
                        width: list.width
                        radius: 6
                        property bool expanded: false
                        height: expanded ? cardColumn.implicitHeight + 18 : 54

                        color: root.cardColor
                        border.width: 1
                        border.color: expanded ? accent : (modelData.connected ? accent : root.borderColor)

                        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
                        Behavior on border.color { ColorAnimation { duration: 180 } }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: card.expanded = !card.expanded
                            onDoubleClicked: root.handleDeviceClick(modelData)
                        }

                        RowLayout {
                            id: cardColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            spacing: 12

                            Rectangle {
                                width: 4
                                height: 34
                                radius: 2
                                Layout.alignment: Qt.AlignTop
                                color: modelData.connected ? accent : theme.surface_variant
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: backend.icon(modelData.connected)
                                        font.family: "JetBrains Mono Nerd Font"
                                        font.pixelSize: 15
                                        color: modelData.connected ? accent : theme.on_surface
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name || "Pairable Device"
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: theme.on_surface
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: modelData.connected
                                        text: "󰄬"
                                        font.family: "JetBrains Mono Nerd Font"
                                        color: accent
                                    }
                                }

                                Text {
                                    text: modelData.connected ? "Connected" : "Disconnected"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 11
                                    color: theme.on_surface_variant
                                }

                                Item {
                                    visible: card.expanded
                                    Layout.fillWidth: true
                                    implicitHeight: details.implicitHeight + 8

                                    ColumnLayout {
                                        id: details
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        spacing: 5

                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 1
                                            color: theme.surface_variant
                                        }

                                        Text {
                                            text: "Address: " + (modelData.address || "Unknown Mac")
                                            color: theme.on_surface_variant
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 11
                                        }

                                        Text {
                                            text: "Paired Status: " + (modelData.paired ? "Yes" : "No")
                                            color: theme.on_surface_variant
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 11
                                        }

                                        Rectangle {
                                            Layout.topMargin: 4
                                            width: 120
                                            height: 30
                                            radius: 5
                                            color: modelData.connected ? theme.error_container : accent

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    root.handleDeviceClick(modelData)
                                                    mouse.accepted = true
                                                }
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.connected ? "Disconnect" : "Connect"
                                                color: modelData.connected ? theme.on_error_container : theme.on_primary
                                                font.family: "JetBrains Mono"
                                                font.pixelSize: 11
                                                font.bold: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
