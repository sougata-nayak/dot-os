// .dot-opt with .dot-check / .dot-radio: an 18px box whose mark is a filled
// block, not a tick. radio: true makes it round.
import QtQuick
import "."

Item {
    id: o
    property bool checked: false
    property bool radio: false
    property alias text: label.text
    signal toggled()

    implicitHeight: T.controlMin
    implicitWidth: 18 + 12 + label.implicitWidth
    width: parent ? parent.width : implicitWidth
    height: implicitHeight
    opacity: enabled ? 1 : 0.4
    activeFocusOnTab: true

    Rectangle {
        id: box
        width: 18; height: 18
        anchors.verticalCenter: parent.verticalCenter
        radius: o.radio ? 9 : T.radiusTechnical
        color: "transparent"
        border.width: 1
        border.color: o.checked ? T.textDisplay : T.textSecondary
        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: o.radio ? width / 2 : 1
            color: T.textDisplay
            visible: o.checked
        }
    }
    Rectangle {
        anchors.fill: box
        anchors.margins: -4
        radius: o.radio ? width / 2 : T.radiusTechnical + 2
        color: "transparent"
        border.width: 2
        border.color: T.textDisplay
        visible: o.activeFocus
    }
    Text {
        id: label
        anchors.left: box.right
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        font.family: T.sans
        font.pixelSize: 14
        color: T.textPrimary
    }
    function activate() { if (enabled) toggled() }
    Keys.onSpacePressed: activate()
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: o.activate()
    }
}
