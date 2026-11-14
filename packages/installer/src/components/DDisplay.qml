// .nil-display: Doto bold, tight tracking.
import QtQuick
import "."

Text {
    property int size: 96
    font.family: T.display
    font.weight: Font.Bold
    font.pixelSize: size
    font.letterSpacing: -size * 0.03
    color: T.textDisplay
    lineHeight: 1
}
