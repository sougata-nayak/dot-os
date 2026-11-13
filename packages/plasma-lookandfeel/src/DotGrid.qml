// The dot grid: 1px-radius dots at a 16px pitch, the only texture in DOT OS.
// A vector tile, so it stays sharp at any display scale.
import QtQuick

Image {
    anchors.fill: parent
    fillMode: Image.Tile
    horizontalAlignment: Image.AlignLeft
    verticalAlignment: Image.AlignTop
    sourceSize: Qt.size(16, 16)
    source: "dot.svg"
    smooth: false
}
