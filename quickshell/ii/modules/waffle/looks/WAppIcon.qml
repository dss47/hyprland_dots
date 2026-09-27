import QtQuick
import org.kde.kirigami as Kirigami
import qs.services
import qs.modules.common

Kirigami.Icon {
    id: root
    required property string iconName
    property bool separateLightDark: false
    property bool tryCustomIcon: true
    
    property real implicitSize: 32
    implicitWidth: implicitSize
    implicitHeight: implicitSize

    animated: false
    roundToIconSize: true
    fallback: root.iconName
    source: tryCustomIcon ? `${Looks.iconsPath}/${root.iconName}${!root.separateLightDark ? "" : Looks.dark ? "-dark" : "-light"}.svg` : fallback

    color: Looks.colors.fg
}
