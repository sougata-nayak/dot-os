// DOT OS wallpaper: the scheme's ground colour and, optionally, the dot grid.
// It follows the colour scheme, so one plugin serves the dark and light themes.
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

WallpaperItem {
    id: root

    Rectangle {
        id: ground
        anchors.fill: parent
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
        readonly property bool dark: (color.r + color.g + color.b) / 3 < 0.5

        DotGrid {
            visible: root.configuration.Grid !== false
            source: ground.dark ? "dot-dark.svg" : "dot-light.svg"
        }
    }
}
