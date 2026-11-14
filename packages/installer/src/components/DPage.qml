// The content area of an install step: surface ground, 32/48px padding and
// the two board columns (440px left, the rest right, 64px apart).
import QtQuick
import "."

Rectangle {
    id: p
    color: T.surface
    default property alias content: leftCol.data
    property alias aside: rightCol.data
    property alias leftColumn: leftCol
    property alias rightColumn: rightCol

    Item {
        id: leftCol
        x: T.padX
        y: T.padY
        width: Math.min(T.colLeft, (p.width - 2 * T.padX - T.colGap) / 2)
        height: p.height - 2 * T.padY
    }
    Item {
        id: rightCol
        x: leftCol.x + leftCol.width + T.colGap
        y: T.padY
        width: p.width - x - T.padX
        height: p.height - 2 * T.padY
    }
}
