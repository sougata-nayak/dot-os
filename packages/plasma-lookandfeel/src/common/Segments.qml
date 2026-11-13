// The segmented meter: 20 square blocks, 2px gaps.
import QtQuick
import org.kde.kirigami as Kirigami

Row {
    id: seg
    property real fraction: 0
    property int count: 20
    property int blockHeight: 10
    property color onColor: Kirigami.Theme.highlightColor
    spacing: 2
    Repeater {
        model: seg.count
        Rectangle {
            width: (seg.width - (seg.count - 1) * seg.spacing) / seg.count
            height: seg.blockHeight
            color: index < Math.round(seg.fraction * seg.count) ? seg.onColor
                 : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.13)
        }
    }
}
