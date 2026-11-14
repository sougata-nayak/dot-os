// .nil-input: mono 16px on a single underline; the caret is the red live mark.
import QtQuick
import QtQuick.Controls.Basic
import "."

TextField {
    id: i
    property bool error: false
    width: parent ? parent.width : implicitWidth
    leftPadding: 0
    rightPadding: 0
    topPadding: 8
    bottomPadding: 8
    font.family: T.mono
    font.pixelSize: 16
    color: T.textPrimary
    placeholderTextColor: T.textDisabled
    selectionColor: T.textDisplay
    selectedTextColor: T.black
    background: Item {
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: i.error ? T.accent : i.activeFocus ? T.textDisplay : T.borderVisible
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
    cursorDelegate: Rectangle {
        width: 2
        color: T.accent
        visible: i.activeFocus
    }
}
