// .dot-body-sm (default) or .dot-sub (sub: true).
import QtQuick
import "."

Text {
    property bool sub: false
    font.family: T.sans
    font.pixelSize: sub ? 18 : 14
    font.letterSpacing: sub ? 0 : 0.14
    color: sub ? T.textPrimary : T.textSecondary
    lineHeight: sub ? 1.3 : 1.5
    wrapMode: Text.WordWrap
}
