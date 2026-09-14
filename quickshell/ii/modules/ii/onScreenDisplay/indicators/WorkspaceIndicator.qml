import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

Item {
    id: root
    readonly property var activeWs: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1

    implicitWidth: wsHUD.implicitWidth
    implicitHeight: wsHUD.implicitHeight

    // Smooth Floating Glass Morphing Workspace Capsule
    Rectangle {
        id: wsHUD
        anchors.centerIn: parent
        implicitHeight: 46
        implicitWidth: wsRow.implicitWidth + 24
        radius: 23
        color: Qt.rgba(0.0, 0.0, 0.0, 0.70)
        border.width: 1.5
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)

        RowLayout {
            id: wsRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: 6 // 6 primary workspace slots

                delegate: Item {
                    required property int index
                    readonly property int wsId: index + 1
                    readonly property bool isActive: root.activeWs === wsId
                    readonly property var biggestWin: HyprlandData.biggestWindowForWorkspace(wsId)
                    readonly property bool isOccupied: Hyprland.workspaces.values.some(ws => ws.id === wsId)
                    readonly property var iconSource: Quickshell.iconPath(AppSearch.guessIcon(biggestWin?.class), "image-missing")

                    implicitWidth: isActive ? 34 : 26
                    implicitHeight: 28

                    Behavior on implicitWidth {
                        NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.implicitWidth
                        height: isActive ? 26 : 22
                        radius: 12
                        color: isActive ? "#cba6f7" : (isOccupied ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06))
                        border.width: isActive ? 1.5 : 0
                        border.color: "#ffffff"

                        Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        // If occupied with app, show micro app icon, otherwise show number
                        IconImage {
                            visible: isOccupied && biggestWin && iconSource !== "" && !isActive
                            anchors.centerIn: parent
                            implicitSize: 14
                            source: iconSource
                            opacity: 0.85
                        }

                        StyledText {
                            visible: isActive || !biggestWin
                            anchors.centerIn: parent
                            font.pixelSize: isActive ? 12 : 10
                            font.weight: Font.Bold
                            font.family: Appearance.font.family.main
                            color: isActive ? "#11111b" : (isOccupied ? "#ffffff" : Qt.rgba(1, 1, 1, 0.40))
                            text: wsId
                        }
                    }
                }
            }
        }
    }
}
