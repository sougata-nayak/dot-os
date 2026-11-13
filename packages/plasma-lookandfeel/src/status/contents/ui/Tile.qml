// A quick-settings tile: label top, state below. On inverts.
import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: tile
    property string label
    property string value
    property bool on: false
    property bool enabled: true
    signal toggled()

    readonly property color cText: Kirigami.Theme.textColor
    radius: 12
    color: on ? Kirigami.Theme.highlightColor : (area.containsMouse ? Qt.rgba(cText.r, cText.g, cText.b, 0.06) : "transparent")
    border.width: 1
    border.color: on ? Kirigami.Theme.highlightColor : Qt.rgba(cText.r, cText.g, cText.b, 0.2)
    opacity: enabled ? 1 : 0.4
    Behavior on color { ColorAnimation { duration: 200 } }

    Text {
        x: 12; y: 12
        text: tile.label
        font.family: "Space Mono"; font.pixelSize: 11; font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        color: tile.on ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
    }
    Text {
        x: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        width: parent.width - 24
        elide: Text.ElideRight
        text: tile.value
        font.family: "Space Grotesk"; font.pixelSize: 14
        color: tile.on ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: tile.enabled
        onClicked: tile.toggled()
    }
}
