import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.synchronizer
import Quickshell
import Quickshell.Io
import qs.modules.ii.sidebarLeft.usbDevices

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: 10
    anchors.fill: parent
    property bool aiChatEnabled: Config.options.policies.ai !== 0
    property bool translatorEnabled: Config.options.sidebar.translator.enable
    property bool animeEnabled: Config.options.policies.weeb !== 0
    property bool animeCloset: Config.options.policies.weeb === 2
    property var tabButtonList: [
        ...(root.aiChatEnabled ? [{"icon": "neurology", "name": Translation.tr("Intelligence")}] : []),
        ...(root.translatorEnabled ? [{"icon": "translate", "name": Translation.tr("Translator")}] : []),
        ...((root.animeEnabled && !root.animeCloset) ? [{"icon": "bookmark_heart", "name": Translation.tr("Anime")}] : [])
    ]
    property int tabCount: swipeView.count

    function focusActiveItem() {
        swipeView.currentItem.forceActiveFocus()
    }

    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                swipeView.incrementCurrentIndex()
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp) {
                swipeView.decrementCurrentIndex()
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: sidebarPadding
        }
        spacing: sidebarPadding

        Toolbar {
            visible: tabButtonList.length > 0
            Layout.alignment: Qt.AlignHCenter
            enableShadow: false
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: swipeView.currentIndex
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: swipeView.implicitWidth
            implicitHeight: swipeView.implicitHeight
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer1

            SwipeView { // Content pages
                id: swipeView
                anchors.fill: parent
                spacing: 10
                currentIndex: tabBar.currentIndex

                clip: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: swipeView.width
                        height: swipeView.height
                        radius: Appearance.rounding.small
                    }
                }

                contentChildren: [
                    ...(root.aiChatEnabled ? [aiChat.createObject()] : []),
                    ...(root.translatorEnabled ? [translator.createObject()] : []),
                    ...((root.tabButtonList.length === 0 || (!root.aiChatEnabled && !root.translatorEnabled && root.animeCloset)) ? [placeholder.createObject()] : []),
                    ...(root.animeEnabled ? [anime.createObject()] : []),
                ]
            }
        }

        Component {
            id: aiChat
            AiChat {}
        }
        Component {
            id: translator
            Translator {}
        }
        Component {
            id: anime
            Anime {}
        }
        Component {
            id: placeholder
            Item {
                id: placeholderRoot
                property var quotes: [
                    "There is nothing outside of yourself that can ever enable you to get better, stronger, richer, quicker, or smarter. Everything is within. Everything exists. Seek nothing outside of yourself.",
                    "Think lightly of yourself and deeply of the world.",
                    "Do not regret what you have done.",
                    "Accept everything just the way it is."
                ]
                property int quoteIndex: Math.floor(Math.random() * quotes.length)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // ── Clean & Minimalist Circular Resource Gauges ──
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 104
                        radius: 16
                        color: Qt.rgba(0.12, 0.12, 0.15, 0.50)
                        border.width: 1
                        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            // ── 1. RAM Circular Gauge ──
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 12
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.04)
                                border.width: 1
                                border.color: Qt.rgba(1.0, 1.0, 1.0, 0.05)

                                readonly property bool isHigh: ResourceUsage.memoryUsedPercentage >= 0.85
                                readonly property color accentCol: isHigh ? "#ff5555" : "#89b4fa"

                                Item {
                                    anchors.centerIn: parent
                                    width: 66
                                    height: 66

                                    CircularProgress {
                                        anchors.fill: parent
                                        implicitSize: 66
                                        lineWidth: 4
                                        value: Math.min(1.0, ResourceUsage.memoryUsedPercentage)
                                        colPrimary: parent.parent.accentCol
                                        colSecondary: Qt.rgba(1.0, 1.0, 1.0, 0.08)
                                        animationDuration: 300
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 1

                                        MaterialSymbol {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: "memory"
                                            iconSize: 16
                                            color: parent.parent.parent.accentCol
                                        }

                                        StyledText {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: Math.round(ResourceUsage.memoryUsedPercentage * 100) + "%"
                                            color: "#ffffff"
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }

                            // ── 2. CPU Temperature Circular Gauge ──
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 12
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.04)
                                border.width: 1
                                border.color: Qt.rgba(1.0, 1.0, 1.0, 0.05)

                                readonly property bool isHigh: ResourceUsage.cpuTemp >= 80
                                readonly property color accentCol: isHigh ? "#ff5555" : (ResourceUsage.cpuTemp >= 70 ? "#fab387" : "#a6e3a1")

                                Item {
                                    anchors.centerIn: parent
                                    width: 66
                                    height: 66

                                    CircularProgress {
                                        anchors.fill: parent
                                        implicitSize: 66
                                        lineWidth: 4
                                        value: Math.min(1.0, Math.max(0, (ResourceUsage.cpuTemp - 30) / 70))
                                        colPrimary: parent.parent.accentCol
                                        colSecondary: Qt.rgba(1.0, 1.0, 1.0, 0.08)
                                        animationDuration: 300
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 1

                                        MaterialSymbol {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: "device_thermostat"
                                            iconSize: 16
                                            color: parent.parent.parent.accentCol
                                        }

                                        StyledText {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: ResourceUsage.cpuTemp + "°C"
                                            color: "#ffffff"
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }

                            // ── 3. CPU Load Circular Gauge ──
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 12
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.04)
                                border.width: 1
                                border.color: Qt.rgba(1.0, 1.0, 1.0, 0.05)

                                readonly property bool isHigh: ResourceUsage.cpuUsage >= 0.85
                                readonly property color accentCol: isHigh ? "#ff5555" : "#cba6f7"

                                Item {
                                    anchors.centerIn: parent
                                    width: 66
                                    height: 66

                                    CircularProgress {
                                        anchors.fill: parent
                                        implicitSize: 66
                                        lineWidth: 4
                                        value: Math.min(1.0, ResourceUsage.cpuUsage)
                                        colPrimary: parent.parent.accentCol
                                        colSecondary: Qt.rgba(1.0, 1.0, 1.0, 0.08)
                                        animationDuration: 300
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 1

                                        MaterialSymbol {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: "planner_review"
                                            iconSize: 16
                                            color: parent.parent.parent.accentCol
                                        }

                                        StyledText {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: Math.round(ResourceUsage.cpuUsage * 100) + "%"
                                            color: "#ffffff"
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Display Projection Section Container (Glass Platter) ──
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: projCol.implicitHeight + 24
                        radius: 18
                        color: Qt.rgba(0.12, 0.12, 0.15, 0.50)
                        border.width: 1
                        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.08)

                        ColumnLayout {
                            id: projCol
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 12
                            }
                            spacing: 8

                            // Section Title
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Layout.leftMargin: 2
                                Layout.bottomMargin: 2

                                MaterialSymbol {
                                    text: "cast"
                                    iconSize: 18
                                    color: Qt.rgba(1.0, 1.0, 1.0, 0.7)
                                }

                                StyledText {
                                    text: Translation.tr("Project Display")
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: "#ffffff"
                                    Layout.fillWidth: true
                                }
                            }

                            // 1. PC screen only
                            ProjectionTileItem {
                                iconText: "laptop"
                                titleText: Translation.tr("PC screen only")
                                descText: Translation.tr("Disable external displays")
                                onActivated: {
                                    Quickshell.execDetached([Quickshell.shellPath("scripts/project_display.sh"), "internal"]);
                                }
                            }

                            // 2. Duplicate
                            ProjectionTileItem {
                                iconText: "content_copy"
                                titleText: Translation.tr("Duplicate")
                                descText: Translation.tr("Mirror display on second screen")
                                onActivated: {
                                    Quickshell.execDetached([Quickshell.shellPath("scripts/project_display.sh"), "duplicate"]);
                                }
                            }

                            // 3. Extend
                            ProjectionTileItem {
                                iconText: "dashboard_customize"
                                titleText: Translation.tr("Extend")
                                descText: Translation.tr("Expand your desktop workspace")
                                isDefaultActive: true
                                onActivated: {
                                    Quickshell.execDetached([Quickshell.shellPath("scripts/project_display.sh"), "extend"]);
                                }
                            }

                            // 4. Second screen only
                            ProjectionTileItem {
                                iconText: "tv"
                                titleText: Translation.tr("Second screen only")
                                descText: Translation.tr("Turn off laptop screen")
                                onActivated: {
                                    Quickshell.execDetached([Quickshell.shellPath("scripts/project_display.sh"), "second"]);
                                }
                            }
                        }
                    }

                    // ── External USB Drives Section ──
                    UsbDevicesWidget {}

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }

    // Component for Projection Options in Left Sidebar
    component ProjectionTileItem: Rectangle {
        id: optRoot
        required property string iconText
        required property string titleText
        required property string descText
        property bool isDefaultActive: false

        signal activated()

        Layout.fillWidth: true
        height: 60
        radius: 14
        color: optMa.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : (optMa.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : (isDefaultActive ? Qt.rgba(0.04, 0.52, 1.0, 0.20) : Qt.rgba(1.0, 1.0, 1.0, 0.05)))
        border.width: 1
        border.color: isDefaultActive ? Qt.rgba(0.04, 0.52, 1.0, 0.50) : Qt.rgba(1.0, 1.0, 1.0, 0.06)

        scale: optMa.pressed ? 0.96 : 1.0
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 120 } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            Rectangle {
                width: 38
                height: 38
                radius: 11
                color: optRoot.isDefaultActive ? "#0a84ff" : Qt.rgba(1.0, 1.0, 1.0, 0.08)

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: optRoot.iconText
                    iconSize: 22
                    color: optRoot.isDefaultActive ? "#ffffff" : Qt.rgba(1.0, 1.0, 1.0, 0.85)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: optRoot.titleText
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                }

                StyledText {
                    text: optRoot.descText
                    font.pixelSize: 12
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.60)
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        MouseArea {
            id: optMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: optRoot.activated()
        }
    }
}