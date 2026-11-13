// A labelled 20-segment meter. Click or drag along it to set the value.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: meter
    property string label
    property string reading
    property real fraction: 0
    property bool interactive: false
    property bool alert: false
    signal picked(real fraction)
    spacing: 8

    readonly property color cText: Kirigami.Theme.textColor

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: meter.label
            font.family: "Space Mono"; font.pixelSize: 11; font.letterSpacing: 0.88
            font.capitalization: Font.AllUppercase
            color: Kirigami.Theme.disabledTextColor
        }
        Item { Layout.fillWidth: true }
        Text {
            text: meter.reading
            font.family: "Space Mono"; font.pixelSize: 12
            color: meter.alert ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
        }
    }
    Item {
        Layout.fillWidth: true
        implicitHeight: 10
        Row {
            anchors.fill: parent
            spacing: 2
            Repeater {
                model: 20
                Rectangle {
                    width: (parent.width - 38) / 20
                    height: 10
                    color: index < Math.round(meter.fraction * 20)
                        ? (meter.alert ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.highlightColor)
                        : Qt.rgba(meter.cText.r, meter.cText.g, meter.cText.b, 0.13)
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            enabled: meter.interactive
            cursorShape: meter.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
            function pick(x) { meter.picked(Math.max(0, Math.min(1, (x - 8) / (width - 16)))); }
            onPressed: mouse => pick(mouse.x)
            onPositionChanged: mouse => { if (pressed) pick(mouse.x); }
        }
    }
}
