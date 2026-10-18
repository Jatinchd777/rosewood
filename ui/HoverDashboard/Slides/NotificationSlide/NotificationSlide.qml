import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications as Notifs

Item {
    id: root
    implicitWidth: 350
    implicitHeight: 450

    ListModel {
        id: localNotifModel
    }

    property color accent: theme.primary

    Notifs.NotificationServer {
        id: notifServer
        bodySupported: true

        onNotification: (notification) => {
            localNotifModel.insert(0, {
                    "notifSummary": notification.summary || "",
                    "notifBody": notification.body || "",
                    "notifAppName": notification.appName || "",
                    "notifUrgency": notification.urgency,
                    "notifObject": notification,
                    "isExpanded": true
            });

            notification.closed.connect(() => {
                    for (var i = 0; i < localNotifModel.count; i++) {
                        if (localNotifModel.get(i).notifObject === notification) {
                            localNotifModel.remove(i);
                            break;
                        }
                    }
            });
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
                text: "󰎟 Clear All"
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 12
                color: localNotifModel.count > 0 ? theme.on_surface : theme.on_surface_variant
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    id: mouseAreaClear
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        for (var i = localNotifModel.count - 1; i >= 0; i--) {
                            var item = localNotifModel.get(i);
                            if (item && item.notifObject) item.notifObject.dismiss();
                        }
                        localNotifModel.clear();
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                visible: localNotifModel.count === 0
                spacing: 8

                Text {
                    text: "󰂛"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 32
                    color: theme.surface_variant
                    Layout.alignment: Qt.AlignCenter
                }
                Text {
                    text: "System is quiet."
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    color: theme.surface_variant
                    Layout.alignment: Qt.AlignCenter
                }
            }

            ListView {
                id: notificationListView
                anchors.fill: parent
                model: localNotifModel
                spacing: 8
                clip: true
                visible: localNotifModel.count > 0

                delegate: Rectangle {
                    id: notifCard
                    width: notificationListView.width
                    height: model.isExpanded ? cardLayout.implicitHeight + 20 : 70
                    color: Qt.alpha(theme.surface, 0.4)
                    radius: 6
                    border.color: Qt.alpha(theme.surface_variant, 0.4)
                    border.width: 1
                    clip: true

                    Behavior on height {
                        NumberAnimation { duration: 350
                            easing.type: Easing.OutQuint
                        }
                    }

                    MouseArea {
                        id: expandArea
                        anchors.fill: parent
                        onClicked: (mouse) => {
                            // Map local coordinate to check against the close button area
                            var closeBtnPos = itemMouseArea.mapFromItem(expandArea, mouse.x, mouse.y)
                            if (itemMouseArea.contains(closeBtnPos)) {
                                if (model.notifObject) model.notifObject.dismiss();
                                localNotifModel.remove(index);
                            } else {
                                localNotifModel.setProperty(index, "isExpanded", !model.isExpanded)
                            }
                        }
                    }

                    RowLayout {
                        id: cardLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 12

                        Rectangle {
                            width: 4
                            Layout.fillHeight: true
                            radius: 2
                            color: model.notifUrgency === 2 ? theme.error : accent
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: model.notifSummary
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: theme.on_surface
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: model.notifAppName
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                    color: theme.on_surface_variant
                                }
                            }

                            Text {
                                text: model.notifBody
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                color: theme.on_surface_variant
                                Layout.fillWidth: true

                                wrapMode: Text.WordWrap
                                maximumLineCount: model.isExpanded ? 100 : 2
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            id: itemMouseArea
                            text: "󰅖"
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 14
                            color: theme.on_surface_variant
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
