pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: mainCol.implicitHeight + 16
    radius: Appearance.rounding.small
    color: Qt.rgba(0.12, 0.12, 0.15, 0.50)
    border.width: 1
    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    visible: usbListModel.count > 0

    ListModel {
        id: usbListModel
    }

    Process {
        id: diskProc
        command: [Quickshell.shellPath("scripts/get_removable_disks.sh")]
        running: false
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data);
                    usbListModel.clear();
                    for (let i = 0; i < parsed.length; i++) {
                        usbListModel.append(parsed[i]);
                    }
                } catch (e) {}
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 1500
        repeat: true
        running: GlobalStates.sidebarRightOpen
        triggeredOnStart: true
        onTriggered: {
            if (!diskProc.running) {
                diskProc.running = true;
            }
        }
    }

    ColumnLayout {
        id: mainCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 8
        }
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            MaterialSymbol {
                text: "usb"
                iconSize: 16
                color: "#89b4fa"
            }

            StyledText {
                text: Translation.tr("USB Drives (%1)").arg(usbListModel.count)
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: "#ffffff"
                Layout.fillWidth: true
            }
        }

        Repeater {
            model: usbListModel
            delegate: Rectangle {
                id: devItem
                required property string name
                required property string devPath
                required property string label
                required property string size
                required property bool mounted
                required property string mountpoint

                Layout.fillWidth: true
                height: 42
                radius: 10
                color: Qt.rgba(1.0, 1.0, 1.0, 0.06)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 8

                    MaterialSymbol {
                        text: "hard_drive"
                        iconSize: 18
                        color: devItem.mounted ? "#a6e3a1" : Qt.rgba(1.0, 1.0, 1.0, 0.6)
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: devItem.label + (devItem.size ? " (" + devItem.size + ")" : "")
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: "#ffffff"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: devItem.mounted ? devItem.mountpoint : Translation.tr("Unmounted")
                            font.pixelSize: 10
                            color: devItem.mounted ? Qt.rgba(1.0, 1.0, 1.0, 0.6) : "#fab387"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Mount / Eject Action Button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: btnMa.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : (btnMa.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : Qt.rgba(1.0, 1.0, 1.0, 0.06))

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: devItem.mounted ? "eject" : "folder_open"
                            iconSize: 16
                            color: devItem.mounted ? "#f38ba8" : "#89b4fa"
                        }

                        MouseArea {
                            id: btnMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (devItem.mounted) {
                                    Quickshell.execDetached(["udisksctl", "unmount", "-b", devItem.devPath]);
                                } else {
                                    Quickshell.execDetached(["udisksctl", "mount", "-b", devItem.devPath]);
                                }
                                refreshTimer.restart();
                            }
                        }
                    }
                }
            }
        }
    }
}
