import QtQuick
import QtQuick.Layouts
import "../../../../core/Managers/"
import "./BlueTooth/"
import "./Network/"
import "./NightLight/"
import "./Awake/"
import "./Aeroplane/"
import "./PowerProfile/"
import "./Volume/"
import "./Brightness/"
import "./Microphone/"
import "./Screenshot/"
import "./ScreenRecord/"

Item {
    id: settingsRoot
    anchors.fill: parent

    property string currentSubState: "default"

    signal requestStateChange(string targetState)

    Item {
        id: mainDeckContainer
        anchors.fill: parent
        visible: settingsRoot.currentSubState === "default"

        Column {
            id: mainLayout
            anchors.fill: parent

            anchors.topMargin: 64
            anchors.leftMargin: 25
            anchors.rightMargin: 25
            anchors.bottomMargin: 20
            spacing: 24

            Flow {
                id: settingsGrid
                width: parent.width
                spacing: 12
                layoutDirection: Qt.LeftToRight

                BlueToothToggle {
                    onRequestSubView: (viewName) => {
                        settingsRoot.requestStateChange(viewName)
                    }
                }

                NetworkToggle {
                    onRequestSubView: (viewName) => {
                        settingsRoot.requestStateChange(viewName)
                    }
                }

                NightLightToggle { }
                AwakeToggle { }
                AeroplaneToggle { }
                PowerProfileToggle { }
                MicrophoneToggle { }
                ScreenshotToggle { }
                ScreenRecordToggle { }
            }

            Column {
                id: sliderRow
                width: parent.width
                spacing: 12
                Volumebar { }
                Brightnessbar { }
            }
        }
    }

    Item {
        id: wifiExpandedLayout
        anchors.fill: parent
        visible: settingsRoot.currentSubState === "wifi_expanded"
        WifiMenu {
            anchors.fill: parent

            onRequestClose: {
                settingsRoot.requestStateChange("default")
            }
        }
    }

    Item {
        id: bluetoothExpandedLayout
        anchors.fill: parent
        visible: settingsRoot.currentSubState === "bt_expanded"

        BluetoothMenu {
            anchors.fill: parent
            onRequestClose: {
                settingsRoot.requestStateChange("default")
            }
        }
    }
}
