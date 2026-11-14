// .nil-btn: primary (filled pill), secondary (outlined pill), ghost (text).
import QtQuick
import "."

Rectangle {
    id: b
    property string kind: "secondary"
    property alias text: label.text
    signal clicked()

    implicitHeight: T.controlMin
    implicitWidth: label.implicitWidth + (kind === "ghost" ? 16 : 48)
    radius: kind === "ghost" ? 0 : height / 2
    color: kind === "primary" ? T.textDisplay : "transparent"
    border.width: kind === "secondary" ? 1 : 0
    border.color: mouse.containsMouse && enabled ? T.textPrimary : T.borderVisible
    opacity: !enabled ? 0.4 : mouse.pressed ? 0.7 : (kind === "primary" && mouse.containsMouse) ? 0.85 : 1
    activeFocusOnTab: true

    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.25, 0.1, 0.25, 1, 1, 1] } }

    Text {
        id: label
        anchors.centerIn: parent
        font.family: T.mono
        font.pixelSize: 13
        font.letterSpacing: 13 * 0.06
        font.capitalization: Font.AllUppercase
        color: b.kind === "primary" ? T.black
             : b.kind === "ghost" ? (mouse.containsMouse && b.enabled ? T.textDisplay : T.textSecondary)
             : T.textPrimary
    }

    // :focus-visible ring, 2px display colour, 2px out.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -4
        radius: b.radius > 0 ? b.radius + 4 : 0
        color: "transparent"
        border.width: 2
        border.color: T.textDisplay
        visible: b.activeFocus && b.focusReason === Qt.TabFocusReason
    }
    property int focusReason: Qt.OtherFocusReason
    onActiveFocusChanged: if (!activeFocus) focusReason = Qt.OtherFocusReason
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) focusReason = Qt.TabFocusReason
    }
    Keys.onReturnPressed: if (enabled) clicked()
    Keys.onSpacePressed: if (enabled) clicked()

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: b.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: b.clicked()
    }
}
