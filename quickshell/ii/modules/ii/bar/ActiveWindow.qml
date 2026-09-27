import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    property string activeWindowAddress: `0x${activeWindow?.HyprlandToplevel?.address}`
    property bool focusingThisMonitor: HyprlandData.activeWorkspace?.monitor == monitor?.name
    property var biggestWindow: HyprlandData.biggestWindowForWorkspace(HyprlandData.monitors[root.monitor?.id]?.activeWorkspace.id)

    implicitWidth: colLayout.implicitWidth

    property var namePalette: ["#7dd87d", "#6aa8e8", "#e05561", "#e8b339"]
    property color nameColor: namePalette[((monitor?.activeWorkspace?.id ?? 1) - 1) % 4]

    // Friendly app name from desktop entries ("Gemini"), raw id as fallback
    property string rawAppId: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ?
        root.activeWindow?.appId : (root.biggestWindow?.class ?? "")
    property var activeDesktopEntry: root.rawAppId !== "" ? DesktopEntries.heuristicLookup(root.rawAppId) : null
    property string friendlyAppName: (activeDesktopEntry?.name ?? "") !== "" ? activeDesktopEntry.name : (root.rawAppId !== "" ? root.rawAppId : Translation.tr("Desktop"))

    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        StyledText {
            Layout.fillWidth: true
            font.family: "JetBrainsMono NFM"
            font.pixelSize: Appearance.font.pixelSize.small
            color: root.nameColor
            elide: Text.ElideRight
            text: root.friendlyAppName.toLowerCase()

        }

    }

}
