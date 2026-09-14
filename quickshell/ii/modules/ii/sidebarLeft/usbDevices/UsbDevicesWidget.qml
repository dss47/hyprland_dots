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
    implicitHeight: usbListModel.count > 0 ? (flowLayout.implicitHeight + 16) : 64
    radius: 16
    color: "#1d1c21"
    border.width: 1
    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.08)

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
        running: GlobalStates.sidebarLeftOpen
        triggeredOnStart: true
        onTriggered: {
            if (!diskProc.running) {
                diskProc.running = true;
            }
        }
    }

    // Empty state (when nothing is plugged in)
    RowLayout {
        id: emptyStateRow
        visible: usbListModel.count === 0
        anchors.centerIn: parent
        spacing: 8

        MaterialSymbol {
            text: "usb_off"
            iconSize: 18
            color: Qt.rgba(1.0, 1.0, 1.0, 0.35)
        }

        StyledText {
            text: Translation.tr("No external drive detected")
            font.pixelSize: 12
            color: Qt.rgba(1.0, 1.0, 1.0, 0.40)
        }
    }

    // USB Buttons flow (when plugged in)
    Flow {
        id: flowLayout
        visible: usbListModel.count > 0
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 8
        }
        spacing: 8

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

                width: 74
                height: 66
                radius: 12
                color: ma.pressed ? "#3b3b42" : (ma.containsMouse ? "#303036" : "#25252a")
                border.width: 1
                border.color: devItem.mounted ? Qt.rgba(0.19, 0.82, 0.35, 0.50) : Qt.rgba(0.95, 0.55, 0.66, 0.50)

                scale: ma.pressed ? 0.94 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 3
                    width: parent.width - 6

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignHCenter
                        text: "usb"
                        iconSize: 22
                        color: devItem.mounted ? "#30d158" : "#f38ba8"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        text: devItem.label
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: ma
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
