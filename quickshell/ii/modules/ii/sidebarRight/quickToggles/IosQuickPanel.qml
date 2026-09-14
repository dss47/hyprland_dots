pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Mpris
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.common.widgets
import qs.modules.common.functions

AbstractQuickPanel {
    id: root
    Layout.fillWidth: true
    implicitHeight: mainLayout.implicitHeight

    readonly property real capsuleRadius: 18
    readonly property color glassBg: Qt.rgba(0.12, 0.12, 0.15, 0.50)
    readonly property color glassBorder: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    readonly property color itemBg: Qt.rgba(1.0, 1.0, 1.0, 0.07)

    readonly property MprisPlayer activePlayer: MprisController.activePlayer

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 12

        // ═══════════════════════════════════════════════════════════════
        // ROW 1: [ 2×2 Connectivity Platter ] + [ Media Player Platter ]
        // ═══════════════════════════════════════════════════════════════
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // ── 1. 2×2 Connectivity Pod ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 148
                radius: root.capsuleRadius
                color: root.glassBg
                border.width: 1
                border.color: root.glassBorder

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    columns: 2
                    rows: 2
                    rowSpacing: 10
                    columnSpacing: 10

                    // 1.1 Airplane Mode
                    Rectangle {
                        id: btnAirplane
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: (Network.wifiStatus === "disabled" && !BluetoothStatus.enabled) ? "#ff9f0a" : (maAirplane.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (maAirplane.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : root.itemBg))
                        scale: maAirplane.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "airplanemode_active"
                            iconSize: 22
                            color: (Network.wifiStatus === "disabled" && !BluetoothStatus.enabled) ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.4)
                        }

                        MouseArea {
                            id: maAirplane
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const disable = (Network.wifiStatus !== "disabled" || BluetoothStatus.enabled);
                                if (disable) {
                                    Network.enableWifi(false);
                                    if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = false;
                                } else {
                                    Network.enableWifi(true);
                                    if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = true;
                                }
                            }
                        }
                    }

                    // 1.2 Wi-Fi Toggle
                    Rectangle {
                        id: btnWifi
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: (Network.wifiStatus === "connected") ? "#0a84ff" : (Network.wifiStatus !== "disabled" ? Qt.rgba(0.04, 0.52, 1.0, 0.35) : (maWifi.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (maWifi.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : root.itemBg)))
                        scale: maWifi.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: Network.wifiStatus === "disabled" ? "wifi_off" : "wifi"
                            iconSize: 22
                            color: (Network.wifiStatus !== "disabled") ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.4)
                        }

                        MouseArea {
                            id: maWifi
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    root.openWifiDialog();
                                } else {
                                    Network.toggleWifi();
                                }
                            }
                            onPressAndHold: root.openWifiDialog()
                        }
                    }

                    // 1.3 Bluetooth Toggle
                    Rectangle {
                        id: btnBt
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: BluetoothStatus.enabled ? "#0a84ff" : (maBt.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (maBt.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : root.itemBg))
                        scale: maBt.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: BluetoothStatus.connected ? "bluetooth_connected" : BluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"
                            iconSize: 22
                            color: BluetoothStatus.enabled ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.4)
                        }

                        MouseArea {
                            id: maBt
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    root.openBluetoothDialog();
                                } else {
                                    if (Bluetooth.defaultAdapter) {
                                        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                                    }
                                }
                            }
                            onPressAndHold: root.openBluetoothDialog()
                        }
                    }

                    // 1.4 Color Picker (Eyedropper / Pen)
                    Rectangle {
                        id: btnCp
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: maCp.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (maCp.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : root.itemBg)
                        scale: maCp.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        ColorPickerToggle {
                            id: cpModel
                        }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "colorize"
                            iconSize: 22
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.85)
                        }

                        MouseArea {
                            id: maCp
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cpModel.mainAction()
                        }
                    }
                }
            }

            // ── 2. Now Playing Platter ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 148
                radius: root.capsuleRadius
                color: root.glassBg
                border.width: 1
                border.color: root.glassBorder
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    // Top: Track Info & Mini Art
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Cover Art / Music Icon
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 10
                            color: root.itemBg
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: root.activePlayer?.trackArtUrl ?? ""
                                fillMode: Image.PreserveAspectCrop
                                visible: root.activePlayer?.trackArtUrl ? true : false
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "music_note"
                                iconSize: 24
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.4)
                                visible: !root.activePlayer?.trackArtUrl
                            }
                        }

                        // Song & Artist Text
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            StyledText {
                                Layout.fillWidth: true
                                text: root.activePlayer?.trackTitle || Translation.tr("Not Playing")
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                                color: "#ffffff"
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: root.activePlayer?.trackArtists?.join(", ") || Translation.tr("Music")
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.6)
                            }
                        }
                    }

                    // Bottom: Playback Controls
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        // Prev
                        Item {
                            width: 32
                            height: 32
                            scale: maPrev.pressed ? 0.85 : (maPrev.containsMouse ? 1.1 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "skip_previous"
                                iconSize: 22
                                color: root.activePlayer?.canGoPrevious ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.3)
                            }
                            MouseArea {
                                id: maPrev
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.activePlayer?.canGoPrevious ?? false
                                onClicked: root.activePlayer.previous()
                            }
                        }

                        // Play/Pause
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: maPlay.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.30) : (maPlay.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.22) : Qt.rgba(1.0, 1.0, 1.0, 0.15))
                            scale: maPlay.pressed ? 0.90 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: (root.activePlayer?.playbackState === MprisPlaybackState.Playing) ? "pause" : "play_arrow"
                                iconSize: 22
                                color: "#ffffff"
                            }
                            MouseArea {
                                id: maPlay
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.activePlayer) root.activePlayer.togglePlaying();
                                }
                            }
                        }

                        // Next
                        Item {
                            width: 32
                            height: 32
                            scale: maNext.pressed ? 0.85 : (maNext.containsMouse ? 1.1 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "skip_next"
                                iconSize: 22
                                color: root.activePlayer?.canGoNext ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.3)
                            }
                            MouseArea {
                                id: maNext
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.activePlayer?.canGoNext ?? false
                                onClicked: root.activePlayer.next()
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════
        // ROW 2: [ 2×2 Quick Controls Grid ] + [ Brightness ] + [ Volume ]
        // ═══════════════════════════════════════════════════════════════
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // ── 1. 2×2 Small Tiles Pod ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 154
                radius: root.capsuleRadius
                color: root.glassBg
                border.width: 1
                border.color: root.glassBorder

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    columns: 2
                    rows: 2
                    rowSpacing: 10
                    columnSpacing: 10

                    // 1.1 Do Not Disturb (DND)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: Notifications.silent ? "#5856d6" : (maDnd.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (maDnd.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : root.itemBg))
                        scale: maDnd.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: Notifications.silent ? "do_not_disturb_on" : "notifications"
                            iconSize: 20
                            color: Notifications.silent ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.7)
                        }

                        MouseArea {
                            id: maDnd
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifications.silent = !Notifications.silent
                        }
                    }

                    // 1.2 Night Light
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: (Hyprsunset.temperature < 6000 || Hyprsunset.gamma < 100) ? "#ff9f0a" : (maNl.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (maNl.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : root.itemBg))
                        scale: maNl.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "nightlight"
                            iconSize: 20
                            color: (Hyprsunset.temperature < 6000 || Hyprsunset.gamma < 100) ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.7)
                        }

                        MouseArea {
                            id: maNl
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.openNightLightDialog()
                        }
                    }

                    // 1.3 Screenshot / Screen Snip
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: maSnip.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (maSnip.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : root.itemBg)
                        scale: maSnip.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        ScreenSnipToggle {
                            id: snipModel
                        }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "screenshot_region"
                            iconSize: 20
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.8)
                        }

                        MouseArea {
                            id: maSnip
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: snipModel.mainAction()
                        }
                    }

                    // 1.4 Power Profile Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: ppModel.toggled ? "#30d158" : (maPp.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (maPp.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : root.itemBg))
                        scale: maPp.pressed ? 0.92 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        PowerProfilesToggle {
                            id: ppModel
                        }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: ppModel.icon
                            iconSize: 20
                            color: ppModel.toggled ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.8)
                        }

                        MouseArea {
                            id: maPp
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ppModel.mainAction()
                        }
                    }
                }
            }

            // ── 2. Brightness Vertical Capsule Slider ──
            Rectangle {
                id: brightCapsule
                Layout.fillWidth: true
                Layout.preferredWidth: 0.5
                implicitHeight: 154
                radius: root.capsuleRadius
                clip: true
                color: root.glassBg
                border.width: 1
                border.color: root.glassBorder

                readonly property var mon: Brightness.getMonitorForScreen(Brightness.monitors[0]?.screen ?? null)
                readonly property real brightVal: (mon?.brightness !== undefined) ? mon.brightness : (Brightness.monitors[0]?.brightness ?? 0.5)

                Rectangle {
                    id: brightFill
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    radius: root.capsuleRadius
                    height: Math.min(1.0, Math.max(0.0, brightCapsule.brightVal)) * brightCapsule.height
                    color: "#ffffff"

                    Behavior on height {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }

                MaterialSymbol {
                    id: brightIcon
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 16
                    }
                    iconSize: 22
                    text: "light_mode"
                    color: (brightFill.height >= 38) ? "#1c1c1e" : Qt.rgba(1.0, 1.0, 1.0, 0.75)
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true

                    function updateBrightness(mouseY) {
                        const clamped = Math.max(0.0, Math.min(1.0, 1.0 - (mouseY / brightCapsule.height)));
                        const targetMon = brightCapsule.mon ?? Brightness.monitors[0];
                        if (targetMon) {
                            targetMon.setBrightness(clamped);
                        }
                    }

                    onPressed: mouse => updateBrightness(mouse.y)
                    onPositionChanged: mouse => {
                        if (pressed) updateBrightness(mouse.y);
                    }
                    onWheel: wheel => {
                        const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                        const targetMon = brightCapsule.mon ?? Brightness.monitors[0];
                        if (targetMon) {
                            targetMon.setBrightness(Math.max(0.0, Math.min(1.0, brightCapsule.brightVal + delta)));
                        }
                    }
                }
            }

            // ── 3. Volume Vertical Capsule Slider ──
            Rectangle {
                id: volCapsule
                Layout.fillWidth: true
                Layout.preferredWidth: 0.5
                implicitHeight: 154
                radius: root.capsuleRadius
                clip: true
                color: root.glassBg
                border.width: 1
                border.color: root.glassBorder

                readonly property real volVal: Audio.sink?.audio?.volume ?? 0
                readonly property bool isMuted: Audio.sink?.audio?.muted ?? false

                Rectangle {
                    id: volFill
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    radius: root.capsuleRadius
                    height: Math.min(1.0, Math.max(0.0, volCapsule.volVal)) * volCapsule.height
                    color: volCapsule.isMuted ? "#f38ba8" : "#ffffff"

                    Behavior on height {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }
                }

                MaterialSymbol {
                    id: volIcon
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 16
                    }
                    iconSize: 22
                    text: {
                        if (volCapsule.isMuted || volCapsule.volVal === 0) return "volume_off";
                        if (volCapsule.volVal < 0.33) return "volume_mute";
                        if (volCapsule.volVal < 0.66) return "volume_down";
                        return "volume_up";
                    }
                    color: (volFill.height >= 38) ? (volCapsule.isMuted ? "#ffffff" : "#1c1c1e") : (volCapsule.isMuted ? "#f38ba8" : Qt.rgba(1.0, 1.0, 1.0, 0.75))
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    preventStealing: true

                    function updateVolume(mouseY) {
                        const clamped = Math.max(0.0, Math.min(1.0, 1.0 - (mouseY / volCapsule.height)));
                        if (Audio.sink?.audio) {
                            Audio.sink.audio.volume = clamped;
                            if (Audio.sink.audio.muted) Audio.sink.audio.muted = false;
                        }
                    }

                    onPressed: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            root.openAudioOutputDialog();
                        } else {
                            updateVolume(mouse.y);
                        }
                    }
                    onPositionChanged: mouse => {
                        if (pressed && !(mouse.buttons & Qt.RightButton)) updateVolume(mouse.y);
                    }
                    onWheel: wheel => {
                        const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                        if (Audio.sink?.audio) {
                            Audio.sink.audio.volume = Math.max(0.0, Math.min(1.0, volCapsule.volVal + delta));
                        }
                    }
                    onPressAndHold: root.openAudioOutputDialog()
                }
            }
        }
    }
}
