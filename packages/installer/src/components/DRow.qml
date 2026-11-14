// .nil-row: label left, mono value right, 1px rule under all but the last.
// `status` + `kind` put a .nil-status mark before the value.
import QtQuick
import "."

Item {
    id: r
    property string label: ""
    property string value: ""
    property string status: ""
    property string kind: ""
    property bool last: false
    property color swatch: "transparent"

    width: parent ? parent.width : 0
    implicitHeight: Math.max(name.implicitHeight, val.implicitHeight) + 24

    Row {
        id: nameRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        Rectangle {
            visible: r.swatch.a > 0
            width: 8; height: 8
            color: r.swatch
            anchors.verticalCenter: parent.verticalCenter
        }
        DLabel { id: name; text: r.label }
    }
    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        DStatus {
            visible: r.status !== ""
            text: r.status + "  "
            kind: r.kind
            anchors.baseline: val.baseline
        }
        Text {
            id: val
            text: r.value
            font.family: T.mono
            font.pixelSize: 14
            color: T.textPrimary
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideLeft
            width: Math.min(implicitWidth, r.width - nameRow.width - 16 - (r.status !== "" ? 100 : 0))
        }
    }
    Rectangle {
        visible: !r.last
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: T.border
    }
}
