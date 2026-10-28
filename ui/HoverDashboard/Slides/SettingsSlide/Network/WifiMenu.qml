import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Networking

Item {
    id: root
    anchors.fill: parent

    signal requestClose()

    property color accent: theme.primary
    property color cardColor: Qt.alpha(theme.surface, 0.4)
    property color borderColor: Qt.alpha(theme.surface_variant, 0.4)
    property color textMuted: theme.on_surface_variant

    function handleNetworkClick(network) {
        if (!network)
        return

        if (typeof network.connect === "function") {
            if (network.connected)
            network.disconnect()
            else
            network.connect()
        } else {
            console.log("Network object has no connect()")
        }
    }

    QtObject {
        id: backend

        property var wifiDevice: Networking.devices.values.find(
            d => d.type === DeviceType.Wifi
        )

        property var networkList: wifiDevice ? wifiDevice.networks.values : []

        function icon(signal) {
            let s = signal <= 1 ? signal * 100 : signal

            if (s >= 75) return "󰤨"
            if (s >= 50) return "󰤥"
            if (s >= 25) return "󰤢"
            return "󰤟"
        }

        function signalName(signal) {
            let s = signal <= 1 ? signal * 100 : signal

            if (s >= 75) return "Excellent Signal"
            if (s >= 50) return "Good Signal"
            if (s >= 25) return "Fair Signal"
            return "Weak Signal"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // Header
        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }

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

            Rectangle {
                id: refreshButton

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: 90
                height: 20
                radius: 17

                color: "transparent"

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (backend.wifiDevice &&
                            typeof backend.wifiDevice.scan === "function") {

                            console.log("Refreshing Wi-Fi scan...")
                            backend.wifiDevice.scan()
                        } else if (backend.wifiDevice &&
                            "scannerEnabled" in backend.wifiDevice) {

                            backend.wifiDevice.scannerEnabled = false
                            backend.wifiDevice.scannerEnabled = true

                            console.log("Restarted Wi-Fi scanner.")
                        } else {
                            console.log("Wi-Fi refresh unsupported.")
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

            // Empty state
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8
                visible: backend.networkList.length === 0

                Text {
                    text: "󰤭"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 34
                    color: theme.error
                    Layout.alignment: Qt.AlignCenter
                }

                Text {
                    text: "No Wi-Fi Networks"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    color: theme.on_surface_variant
                    Layout.alignment: Qt.AlignCenter
                }

                Text {
                    text: "Enable Wi-Fi or scan again."
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    color: theme.on_surface_variant
                    Layout.alignment: Qt.AlignCenter
                }
            }

            ListView {
                id: list

                anchors.fill: parent
                anchors.bottomMargin: 35
                visible: backend.networkList.length > 0
                spacing: 8
                clip: true

                model: backend.networkList

                delegate: Rectangle {
                    id: card

                    width: list.width
                    radius: 6

                    property bool expanded: false

                    height: expanded ? cardColumn.implicitHeight + 18 : 54

                    color: root.cardColor
                    border.width: 1
                    border.color: expanded
                    ? accent
                    : (modelData.connected ? accent : root.borderColor)

                    Behavior on height {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutQuint
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 180
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            card.expanded = !card.expanded
                        }

                        onDoubleClicked: {
                            root.handleNetworkClick(modelData)
                        }
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
                            //Layout.fillHeight: true
                            color: modelData.connected ? accent : theme.on_primary
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: backend.icon(modelData.signalStrength)
                                    font.family: "JetBrains Mono Nerd Font"
                                    font.pixelSize: 15
                                    color: modelData.connected ? accent : theme.on_surface
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name || "Hidden Network"
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

                                Text {
                                    visible: !!(modelData.secure && !modelData.connected)
                                    text: "󰌾"
                                    font.family: "JetBrains Mono Nerd Font"
                                    color: theme.on_surface_variant
                                }
                            }

                            Text {
                                text: backend.signalName(modelData.signalStrength)
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
                                        text: "Connected: " + (modelData.connected ? "Yes" : "No")
                                        color: theme.on_surface_variant
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 11
                                    }

                                    Text {
                                        text: "Strength: " +
                                        Math.round((modelData.signalStrength <= 1
                                                ? modelData.signalStrength * 100
                                                : modelData.signalStrength)) + "%"
                                        color: theme.on_surface_variant
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 11
                                    }

                                    Text {
                                        visible: modelData.secure !== undefined
                                        text: "Security: " + (modelData.secure ? "Secured" : "Open")
                                        color: theme.on_surface_variant
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 11
                                    }

                                    Rectangle {
                                        Layout.topMargin: 4
                                        width: 120
                                        height: 30
                                        radius: 5

                                        color: modelData.connected
                                        ? theme.primary_container
                                        : accent

                                        MouseArea {
                                            anchors.fill: parent

                                            onClicked: {
                                                root.handleNetworkClick(modelData)
                                                mouse.accepted = true
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.connected
                                            ? "Disconnect"
                                            : "Connect"

                                            color: modelData.connected
                                            ? theme.on_primary_container
                                            : theme.on_primary

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
