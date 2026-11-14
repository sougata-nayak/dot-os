// .nil-field: label, control, message. error: true draws the red dot and
// turns the control's underline red (DInput reads `error` from its field).
import QtQuick
import "."

Column {
    id: f
    property string label: ""
    property string message: ""
    property bool error: false
    // Keep the message line's height even while it is empty, so a message
    // appearing does not push the fields below it down.
    property bool reserveMessage: false
    default property alias content: holder.data
    spacing: 8

    DLabel { text: f.label; visible: text !== "" }
    Item {
        id: holder
        width: f.width
        height: childrenRect.height
    }
    Row {
        visible: f.message !== "" || f.reserveMessage
        opacity: f.message !== "" ? 1 : 0
        spacing: 8
        Rectangle {
            visible: f.error
            width: 6; height: 6; radius: 3
            color: T.accent
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: f.message !== "" ? f.message : " "
            width: f.width - (f.error ? 14 : 0)
            wrapMode: Text.WordWrap
            font.family: T.mono
            font.pixelSize: 12
            font.letterSpacing: 12 * 0.04
            font.capitalization: Font.AllUppercase
            color: T.textSecondary
        }
    }
}
