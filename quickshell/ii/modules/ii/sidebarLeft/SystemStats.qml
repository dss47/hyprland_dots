import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

StyledFlickable {
    id: root
    contentHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout
        width: root.width
        spacing: 24

        // Add padding at the top and bottom inside the scroll view
        Item { Layout.preferredHeight: 4 }

        // --- User & System Profile Card ---
        Rectangle {
            Layout.fillWidth: true
            Layout.margins: 16
            Layout.bottomMargin: 0
            implicitHeight: profileLayout.implicitHeight + 32
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer1
            
            StyledRectangularShadow { target: parent }

            RowLayout {
                id: profileLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Icon Container
                Rectangle {
                    width: 64
                    height: 64
                    radius: Appearance.rounding.full
                    color: Appearance.colors.colPrimaryContainer

                    CustomIcon {
                        anchors.centerIn: parent
                        width: 36
                        height: 36
                        source: SystemInfo.distroIcon
                        colorize: true
                        color: Appearance.colors.colOnPrimaryContainer
                    }
                }

                // Profile Text
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    StyledText {
                        text: SystemInfo.username + "@" + SystemInfo.distroName
                        color: Appearance.colors.colOnLayer1
                        font.family: Appearance.font.family.title
                        font.weight: Font.DemiBold
                        font.pixelSize: Appearance.font.pixelSize.larger
                    }

                    StyledText {
                        text: SystemInfo.desktopEnvironment + " (" + SystemInfo.windowingSystem + ")"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                    
                    StyledText {
                        text: "Quickshell Dashboard"
                        color: Appearance.colors.colPrimary
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.italic: true
                        font.weight: Font.Medium
                    }
                }
            }
        }

        // --- Hardware Monitor Section ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            spacing: 16

            // Section Title
            StyledText {
                text: "SYSTEM RESOURCES"
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.Bold
                font.letterSpacing: 2
                Layout.bottomMargin: -4
                Layout.leftMargin: 4
            }

            // CPU Card
            ResourceCard {
                title: "CPU"
                icon: "planner_review"
                usageValue: ResourceUsage.cpuUsage
                history: ResourceUsage.cpuUsageHistory
                details: ResourceUsage.maxAvailableCpuString
                accentColor: Appearance.colors.colPrimary
            }

            // RAM Card
            ResourceCard {
                title: "Memory"
                icon: "memory"
                usageValue: ResourceUsage.memoryUsedPercentage
                history: ResourceUsage.memoryUsageHistory
                details: ResourceUsage.kbToGbString(ResourceUsage.memoryUsed) + " / " + ResourceUsage.maxAvailableMemoryString
                accentColor: Appearance.colors.colSecondary
            }

            // Swap Card
            ResourceCard {
                title: "Swap"
                icon: "swap_horiz"
                usageValue: ResourceUsage.swapUsedPercentage
                history: ResourceUsage.swapUsageHistory
                details: ResourceUsage.kbToGbString(ResourceUsage.swapUsed) + " / " + ResourceUsage.maxAvailableSwapString
                accentColor: Appearance.colors.colTertiary
            }
        }

        Item { Layout.preferredHeight: 16 } // Bottom padding
    }

    // --- Reusable Resource Card Component ---
    component ResourceCard: Rectangle {
        id: card
        property string title
        property string icon
        property real usageValue
        property list<real> history
        property string details
        property color accentColor

        Layout.fillWidth: true
        implicitHeight: cardLayout.implicitHeight + 32
        radius: Appearance.rounding.small
        color: Appearance.colors.colLayer1

        StyledRectangularShadow { target: parent }

        ColumnLayout {
            id: cardLayout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Top Row (Title + Percentage)
            RowLayout {
                Layout.fillWidth: true
                
                MaterialSymbol {
                    text: card.icon
                    color: card.accentColor
                    iconSize: 22
                }

                StyledText {
                    text: card.title
                    color: Appearance.colors.colOnLayer1
                    font.family: Appearance.font.family.title
                    font.weight: Font.DemiBold
                    font.pixelSize: Appearance.font.pixelSize.large
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                }

                // Usage Percentage Badge
                Rectangle {
                    width: usageText.implicitWidth + 16
                    height: usageText.implicitHeight + 8
                    radius: height / 2
                    color: ColorUtils.transparentize(card.accentColor, 0.15)

                    StyledText {
                        id: usageText
                        anchors.centerIn: parent
                        text: Math.round(card.usageValue * 100) + "%"
                        color: card.accentColor
                        font.family: Appearance.font.family.monospace
                        font.weight: Font.Bold
                        font.pixelSize: Appearance.font.pixelSize.smallie
                    }
                }
            }

            // Graph Area
            Rectangle {
                Layout.fillWidth: true
                height: 80
                radius: Appearance.rounding.verysmall
                color: Appearance.colors.colLayer0 // Inset look

                Graph {
                    anchors.fill: parent
                    anchors.margins: 4
                    values: card.history
                    points: ResourceUsage.historyLength
                    alignment: Graph.Alignment.Right
                    color: card.accentColor
                    fillOpacity: 0.25 // Slightly more opaque
                }
            }

            // Details Row
            RowLayout {
                Layout.fillWidth: true
                
                Item { Layout.fillWidth: true } // Spacer

                StyledText {
                    text: card.details
                    color: Appearance.colors.colSubtext
                    font.family: Appearance.font.family.monospace
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
        }
    }
}
