import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root
    required property real value
    required property string icon
    required property string name
    property bool rotateIcon: false
    property bool scaleIcon: true
    property real from: 0
    property real to: 1.0

    readonly property real fillFraction: Math.min(Math.max((root.value - root.from) / (root.to - root.from), 0), 1.0)
    readonly property bool isMuted: root.icon.includes("off") || root.icon.includes("muted")

    implicitWidth: 160
    implicitHeight: 160

    // Concentric Orbit Glass Badge
    Rectangle {
        id: dialBackdrop
        anchors.centerIn: parent
        width: 140
        height: 140
        radius: 70
        color: Qt.rgba(0.0, 0.0, 0.0, 0.70)
        border.width: 1.5
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)

        // Subtle Outer Glow Ring
        Rectangle {
            anchors.centerIn: parent
            width: 126
            height: 126
            radius: 63
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.06)
        }

        // Circular Orbital Track Background
        ClippedFilledCircularProgress {
            anchors.centerIn: parent
            implicitSize: 110
            lineWidth: 6
            value: root.fillFraction
            enableAnimation: true
            animationDuration: 180
            colPrimary: root.isMuted ? "#f38ba8" : "#cba6f7"
            accountForLightBleeding: false

            // Center Content (Icon + Bouncy Number)
            ColumnLayout {
                anchors.centerIn: parent
                spacing: -2

                // Icon that pops and rotates playfully
                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.icon
                    iconSize: 28
                    color: root.isMuted ? "#f38ba8" : "#ffffff"

                    scale: 1.0
                    Behavior on scale {
                        SequentialAnimation {
                            NumberAnimation { to: 1.35; duration: 90; easing.type: Easing.OutBack }
                            NumberAnimation { to: 1.0; duration: 150; easing.type: Easing.OutElastic }
                        }
                    }
                }

                // Value Counter
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.family: Appearance.font.family.main
                    color: "#ffffff"
                    text: `${Math.round(root.fillFraction * 100)}%`
                }
            }
        }
    }
}
