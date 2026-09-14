pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

Scope {
    id: root
    property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]

    function triggerOsd() {
        GlobalStates.osdVolumeOpen = true;
        osdTimeout.restart();
    }

    Timer {
        id: osdTimeout
        interval: 2200
        repeat: false
        running: false
        onTriggered: {
            GlobalStates.osdVolumeOpen = false;
        }
    }

    // 1. BRIGHTNESS LISTENER
    Connections {
        target: Brightness
        function onBrightnessChanged() {
            root.triggerOsd();
        }
    }

    // 2. VOLUME LISTENER
    Connections {
        target: Audio.sink?.audio ?? null
        function onVolumeChanged() {
            if (!Audio.ready) return;
            root.triggerOsd();
        }
        function onMutedChanged() {
            if (!Audio.ready) return;
            root.triggerOsd();
        }
    }

    // Dual Android / iOS Multi-Slider OSD Panel on Right Edge
    Loader {
        id: osdLoader
        active: GlobalStates.osdVolumeOpen

        sourceComponent: PanelWindow {
            id: osdRoot
            color: "transparent"
            screen: root.focusedScreen

            WlrLayershell.namespace: "quickshell:dualSliderOsd"
            WlrLayershell.layer: WlrLayer.Overlay
            
            anchors {
                right: true
            }
            margins {
                right: 24
            }

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0

            implicitWidth: 154
            implicitHeight: 200
            visible: osdLoader.active

            readonly property real volumeVal: Audio.sink?.audio?.volume ?? 0
            readonly property bool isMuted: Audio.sink?.audio?.muted ?? false
            readonly property var mon: Brightness.getMonitorForScreen(root.focusedScreen)
            readonly property real brightnessVal: (mon?.brightness !== undefined) ? mon.brightness : (Brightness.monitors[0]?.brightness ?? 0.5)

            // Dual Slider Row: [Brightness] + [Volume]
            Row {
                anchors.centerIn: parent
                spacing: 10

                // ── 1. Brightness Slider Capsule ──
                Rectangle {
                    id: brightnessCapsule
                    width: 60
                    height: 180
                    radius: 20
                    clip: true

                    color: Qt.rgba(0.12, 0.12, 0.14, 0.60)
                    border.width: 1
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)

                    Item {
                        anchors.fill: parent
                        clip: true

                        Rectangle {
                            id: brightnessFill
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            radius: 20
                            height: Math.min(Math.max(osdRoot.brightnessVal, 0), 1.0) * brightnessCapsule.height
                            color: "#ffffff"

                            Behavior on height {
                                NumberAnimation {
                                    duration: 140
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    // Brightness Icon
                    MaterialSymbol {
                        id: brightIcon
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: 20
                        }
                        iconSize: 24
                        color: (brightnessFill.height >= (brightIcon.anchors.bottomMargin + 24)) ? "#2c2c2e" : Qt.rgba(1.0, 1.0, 1.0, 0.65)
                        text: "light_mode"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        function updateBrightness(mouseY) {
                            root.triggerOsd();
                            const clamped = Math.max(0.0, Math.min(1.0, 1.0 - (mouseY / brightnessCapsule.height)));
                            const targetMon = osdRoot.mon ?? Brightness.monitors[0];
                            if (targetMon) {
                                targetMon.setBrightness(clamped);
                            }
                        }

                        onPressed: mouse => updateBrightness(mouse.y)
                        onPositionChanged: mouse => {
                            if (pressed) updateBrightness(mouse.y);
                        }
                        onWheel: wheel => {
                            root.triggerOsd();
                            const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                            const targetMon = osdRoot.mon ?? Brightness.monitors[0];
                            if (targetMon) {
                                targetMon.setBrightness(Math.max(0.0, Math.min(1.0, osdRoot.brightnessVal + delta)));
                            }
                        }
                    }
                }

                // ── 2. Volume Slider Capsule ──
                Rectangle {
                    id: volumeCapsule
                    width: 60
                    height: 180
                    radius: 20
                    clip: true

                    color: Qt.rgba(0.12, 0.12, 0.14, 0.60)
                    border.width: 1
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)

                    Item {
                        anchors.fill: parent
                        clip: true

                        Rectangle {
                            id: volumeFill
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            radius: 20
                            height: Math.min(Math.max(osdRoot.volumeVal, 0), 1.0) * volumeCapsule.height
                            color: osdRoot.isMuted ? "#f38ba8" : "#ffffff"

                            Behavior on height {
                                NumberAnimation {
                                    duration: 140
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                        }
                    }

                    // Volume Icon
                    MaterialSymbol {
                        id: volIcon
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: 20
                        }
                        iconSize: 24
                        color: (volumeFill.height >= (volIcon.anchors.bottomMargin + 24)) ? (osdRoot.isMuted ? "#ffffff" : "#2c2c2e") : (osdRoot.isMuted ? "#f38ba8" : Qt.rgba(1.0, 1.0, 1.0, 0.65))
                        text: {
                            if (osdRoot.isMuted || osdRoot.volumeVal === 0) return "volume_off";
                            if (osdRoot.volumeVal < 0.33) return "volume_mute";
                            if (osdRoot.volumeVal < 0.66) return "volume_down";
                            return "volume_up";
                        }
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true

                        function updateVolume(mouseY) {
                            root.triggerOsd();
                            const clamped = Math.max(0.0, Math.min(1.0, 1.0 - (mouseY / volumeCapsule.height)));
                            if (Audio.sink?.audio) {
                                Audio.sink.audio.volume = clamped;
                                if (Audio.sink.audio.muted) Audio.sink.audio.muted = false;
                            }
                        }

                        onPressed: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                if (Audio.sink?.audio) Audio.sink.audio.muted = !Audio.sink.audio.muted;
                                root.triggerOsd();
                            } else {
                                updateVolume(mouse.y);
                            }
                        }
                        onPositionChanged: mouse => {
                            if (pressed && !(mouse.buttons & Qt.RightButton)) updateVolume(mouse.y);
                        }
                        onWheel: wheel => {
                            root.triggerOsd();
                            const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                            if (Audio.sink?.audio) {
                                Audio.sink.audio.volume = Math.max(0.0, Math.min(1.0, osdRoot.volumeVal + delta));
                            }
                        }
                    }
                }
            }
        }
    }
}
