import qs
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

WindowDialog {
    id: root
    backgroundHeight: 480

    WindowDialogTitle {
        text: Translation.tr("Project Display")
    }

    WindowDialogSeparator {}

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        // 1. PC screen only
        ProjectionDialogItem {
            iconText: "laptop"
            titleText: Translation.tr("PC screen only")
            descText: Translation.tr("Disable external displays")
            onActivated: {
                root.dismiss();
                Quickshell.execDetached(["bash", `${Directories.config}/quickshell/ii/scripts/project_display.sh`, "internal"]);
            }
        }

        // 2. Duplicate
        ProjectionDialogItem {
            iconText: "content_copy"
            titleText: Translation.tr("Duplicate")
            descText: Translation.tr("Mirror display on second screen")
            onActivated: {
                root.dismiss();
                Quickshell.execDetached(["bash", `${Directories.config}/quickshell/ii/scripts/project_display.sh`, "duplicate"]);
            }
        }

        // 3. Extend
        ProjectionDialogItem {
            iconText: "dashboard_customize"
            titleText: Translation.tr("Extend")
            descText: Translation.tr("Expand your desktop workspace")
            isDefaultActive: true
            onActivated: {
                root.dismiss();
                Quickshell.execDetached(["bash", `${Directories.config}/quickshell/ii/scripts/project_display.sh`, "extend"]);
            }
        }

        // 4. Second screen only
        ProjectionDialogItem {
            iconText: "tv"
            titleText: Translation.tr("Second screen only")
            descText: Translation.tr("Turn off laptop screen")
            onActivated: {
                root.dismiss();
                Quickshell.execDetached(["bash", `${Directories.config}/quickshell/ii/scripts/project_display.sh`, "second"]);
            }
        }
    }

    WindowDialogSeparator {}

    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Display Settings")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'kcmshell6 kcm_kscreen' 'wdisplays' 'nwg-displays'"]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: Translation.tr("Done")
            onClicked: root.dismiss()
        }
    }

    component ProjectionDialogItem: DialogListItem {
        id: itemRoot
        required property string iconText
        required property string titleText
        required property string descText
        property bool isDefaultActive: false

        signal activated()
        onClicked: itemRoot.activated()

        contentItem: RowLayout {
            anchors {
                fill: parent
                margins: 8
            }
            spacing: 12

            Rectangle {
                width: 36
                height: 36
                radius: 10
                color: itemRoot.isDefaultActive ? "#0a84ff" : Appearance.colors.colLayer2

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: itemRoot.iconText
                    iconSize: 20
                    color: itemRoot.isDefaultActive ? "#ffffff" : Appearance.colors.colOnLayer2
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                StyledText {
                    text: itemRoot.titleText
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnLayer0
                }

                StyledText {
                    text: itemRoot.descText
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
}
