// .nil-status: "[ OK ]", "[ WARN ]"... kind: good | warn | bad | "" (neutral).
import QtQuick
import "."

Text {
    property string kind: ""
    font.family: T.mono
    font.pixelSize: 12
    font.letterSpacing: 12 * 0.04
    font.capitalization: Font.AllUppercase
    color: kind === "good" ? T.success : kind === "warn" ? T.warning : kind === "bad" ? T.accent : T.textSecondary
}
