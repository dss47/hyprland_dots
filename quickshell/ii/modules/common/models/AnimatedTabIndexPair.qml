import QtQuick
import qs.modules.common

// idx1 is the "leading" indicator position, idx2 is the "following" one
// Smooth spring-like fluid glide across workspace switches
QtObject {
    id: root
    required property int index

    property real idx1: index
    property real idx2: index
    property int idx1Duration: 280
    property int idx2Duration: 420

    Behavior on idx1 {
        NumberAnimation {
            duration: root.idx1Duration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.05, 0.9, 0.1, 1.0, 1.0, 1.0]
        }
    }
    Behavior on idx2 {
        NumberAnimation {
            duration: root.idx2Duration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.1, 0.95, 0.2, 1.0, 1.0, 1.0]
        }
    }
}
