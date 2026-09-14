import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

Scope {
    id: root

    property int focusedWorkspaceId: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1
    property bool popupVisible: false

    onFocusedWorkspaceIdChanged: {
        popupVisible = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1600
        repeat: false
        onTriggered: {
            root.popupVisible = false;
        }
    }

    Loader {
        active: root.popupVisible

        sourceComponent: Variants {
            model: Quickshell.screens
            delegate: PanelWindow {
                id: wsOsdWindow
                required property var modelData
                screen: modelData

                anchors {
                    top: true
                }
                margins {
                    top: 42
                }

                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: 0

                implicitWidth: 520
                implicitHeight: 68
                color: "transparent"

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "quickshell:workspace-osd"

                // Main Floating Capsule Pill matching the OSD Slider style
                Rectangle {
                    id: pillBackground
                    anchors.centerIn: parent
                    width: wsRow.implicitWidth + 24
                    height: 54
                    radius: 24

                    // Exact translucent dark glass material from the OSD Sliders
                    color: Qt.rgba(0.12, 0.12, 0.14, 0.60)
                    border.width: 1
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)

                    opacity: root.popupVisible ? 1.0 : 0.0
                    scale: root.popupVisible ? 1.0 : 0.88

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutBack
                        }
                    }

                    // Inner Row with App Logos & Numbers
                    Row {
                        id: wsRow
                        anchors.centerIn: parent
                        spacing: 8

                        Repeater {
                            model: 10 // Workspaces 1 to 10

                            Rectangle {
                                id: wsPill
                                property int wsNum: index + 1
                                property bool isActive: root.focusedWorkspaceId === wsNum
                                property var biggestWindow: HyprlandData.biggestWindowForWorkspace(wsNum)
                                property var iconSource: biggestWindow?.class ? Quickshell.iconPath(AppSearch.guessIcon(biggestWindow.class), "image-missing") : ""
                                property bool hasIcon: iconSource !== "" && iconSource !== "image-missing"

                                width: isActive ? 44 : 34
                                height: 34
                                radius: 17

                                // Pure white active fill matching the slider fill, subtle translucent for inactive
                                color: isActive ? "#ffffff" : (hasIcon ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : Qt.rgba(1.0, 1.0, 1.0, 0.10))
                                border.width: isActive ? 0 : 1
                                border.color: Qt.rgba(1.0, 1.0, 1.0, 0.08)

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 240
                                        easing.type: Easing.BezierSpline
                                        easing.bezierCurve: [0.05, 0.9, 0.1, 1.0, 1.0, 1.0]
                                    }
                                }
                                Behavior on color {
                                    ColorAnimation { duration: 160 }
                                }

                                // Application Logo if workspace is occupied
                                Image {
                                    visible: wsPill.hasIcon
                                    anchors.centerIn: parent
                                    width: wsPill.isActive ? 22 : 18
                                    height: width
                                    source: wsPill.iconSource
                                    sourceSize.width: 32
                                    sourceSize.height: 32
                                    smooth: true
                                    mipmap: true

                                    Behavior on width {
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }
                                }

                                // Fallback Workspace Number if workspace is empty
                                StyledText {
                                    visible: !wsPill.hasIcon
                                    anchors.centerIn: parent
                                    text: wsPill.wsNum
                                    font {
                                        family: Appearance.font.family.title
                                        pixelSize: wsPill.isActive ? 14 : 12
                                        weight: wsPill.isActive ? Font.Bold : Font.Normal
                                    }
                                    color: wsPill.isActive ? "#1c1c1e" : Qt.rgba(1.0, 1.0, 1.0, 0.60)
                                    Behavior on color { ColorAnimation { duration: 140 } }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
