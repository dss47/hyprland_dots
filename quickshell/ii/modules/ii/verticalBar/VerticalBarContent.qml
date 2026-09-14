import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import Quickshell.Hyprland
import Quickshell.Widgets
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root

    property var screen: root.QsWindow.window?.screen
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    readonly property int effectiveActiveWorkspaceId: monitor?.activeWorkspace?.id ?? 1

    // Ultra-smooth dark glass backdrop matching terminal 0.60 opacity
    Rectangle {
        id: barBackground
        anchors {
            fill: parent
            topMargin: 6
            bottomMargin: 6
            leftMargin: 2
            rightMargin: 2
        }
        color: Qt.rgba(0.0, 0.0, 0.0, 0.60)
        radius: 15
        border.width: 1
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    }

    // Main Content
    ColumnLayout {
        anchors {
            fill: parent
            topMargin: 12
            bottomMargin: 12
            leftMargin: 0
            rightMargin: 0
        }
        spacing: 0

        // ====================================================
        // 1. TOP: CONNECTIVITY & STATUS (Clean & Borderless)
        // ====================================================
        MouseArea {
            id: topStatusArea
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 26
            implicitHeight: topStatusCol.implicitHeight + 4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
            }

            ColumnLayout {
                id: topStatusCol
                anchors.centerIn: parent
                spacing: 6

                // WiFi / Network
                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    text: Network.materialSymbol
                    iconSize: 15
                    color: topStatusArea.containsMouse ? "#ffffff" : "#a6c8ff"
                }

                // Bluetooth (Only when connected/enabled)
                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    visible: BluetoothStatus.available && (BluetoothStatus.connected || BluetoothStatus.enabled)
                    text: BluetoothStatus.connected ? "bluetooth_connected" : "bluetooth"
                    iconSize: 13
                    color: BluetoothStatus.connected ? "#a6e3a1" : "#7d7888"
                }

                // Volume Mute
                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    visible: Audio.sink?.audio?.muted ?? false
                    text: "volume_off"
                    iconSize: 13
                    color: "#f38ba8"
                }

                // Notification Dot
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    visible: Notifications.unread > 0
                    implicitWidth: 4
                    implicitHeight: 4
                    radius: 2
                    color: "#fab387"
                }
            }
        }

        Item { Layout.fillHeight: true }

        // ====================================================
        // 2. CENTER: COLORFUL APP ICONS (NO BACKGROUND BOXES)
        // ====================================================
        ColumnLayout {
            id: wsLayout
            Layout.alignment: Qt.AlignHCenter
            spacing: 5

            Repeater {
                model: 8

                delegate: Item {
                    required property int index
                    readonly property int wsId: index + 1
                    readonly property bool isActive: root.effectiveActiveWorkspaceId === wsId
                    readonly property var biggestWin: HyprlandData.biggestWindowForWorkspace(wsId)
                    readonly property bool isOccupied: Hyprland.workspaces.values.some(ws => ws.id === wsId)
                    readonly property var iconSource: Quickshell.iconPath(AppSearch.guessIcon(biggestWin?.class), "image-missing")

                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 26
                    implicitHeight: 22

                    // Active subtle glow/indicator line
                    Rectangle {
                        anchors {
                            right: parent.right
                            rightMargin: -2
                            verticalCenter: parent.verticalCenter
                        }
                        width: 2.5
                        height: isActive ? 14 : 0
                        radius: 1.25
                        color: "#cba6f7"
                        visible: isActive

                        Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                    }

                    // Native Colorful App Icon (Borderless & Clean)
                    IconImage {
                        id: appIcon
                        visible: isOccupied && biggestWin && iconSource !== ""
                        anchors.centerIn: parent
                        implicitSize: isActive ? 16 : 14
                        source: iconSource
                        opacity: isActive ? 1.0 : (wsMouseArea.containsMouse ? 0.95 : 0.65)

                        Behavior on opacity { NumberAnimation { duration: 120 } }
                        Behavior on implicitSize { NumberAnimation { duration: 120 } }
                    }

                    // Fallback minimal dot for occupied/empty workspace without window
                    Rectangle {
                        visible: !appIcon.visible
                        anchors.centerIn: parent
                        width: isActive ? 10 : (isOccupied ? 5 : 3.5)
                        height: isActive ? 6 : (isOccupied ? 5 : 3.5)
                        radius: isActive ? 3 : 2
                        color: isActive ? "#cba6f7" : (isOccupied ? "#ffffff" : Qt.rgba(1, 1, 1, 0.20))

                        Behavior on width { NumberAnimation { duration: 120 } }
                        Behavior on height { NumberAnimation { duration: 120 } }
                    }

                    MouseArea {
                        id: wsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${wsId}})`)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // ====================================================
        // 3. BOTTOM: CLEAN TIME & MICRO BATTERY STATUS
        // ====================================================
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 1

            // Hours
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 11
                font.weight: Font.Bold
                color: "#ffffff"
                text: DateTime.time.split(/[: ]/)[0] || "12"
            }

            // Minutes
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: "#cba6f7"
                text: DateTime.time.split(/[: ]/)[1] || "00"
            }

            // Battery (Discrete minimal line/chip)
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 3
                visible: Battery.available
                spacing: 1

                MaterialSymbol {
                    text: Battery.isCharging ? "bolt" : (Battery.percentage <= 0.2 ? "battery_alert" : "battery_full")
                    iconSize: 9
                    color: Battery.isCharging ? "#a6e3a1" : (Battery.percentage <= 0.2 ? "#f38ba8" : "#bac2de")
                }

                StyledText {
                    font.pixelSize: 8
                    font.weight: Font.Bold
                    color: Battery.isCharging ? "#a6e3a1" : "#bac2de"
                    text: Math.round(Battery.percentage * 100)
                }
            }
        }
    }
}
