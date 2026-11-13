// A ListRow: label left, mono value right, hairline under.
import QtQuick
import org.kde.kirigami as Kirigami

Item {
    property alias label: l.text
    property alias value: v.text
    property alias unit: u.text
    property bool last: false
    implicitHeight: 46
    Label { id: l; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }
    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        Text {
            id: v
            font.family: "Space Mono"
            font.pixelSize: 14
            color: Kirigami.Theme.textColor
        }
        Label { id: u; visible: text !== ""; anchors.top: parent.top }
    }
    Rectangle {
        visible: !parent.last
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.13)
    }
}
