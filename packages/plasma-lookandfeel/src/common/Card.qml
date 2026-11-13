// The SystemWidget card: surface, 1px outline, radius-widget, 24px padding.
import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    default property alias content: inner.data
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Button
    color: Kirigami.Theme.backgroundColor
    radius: 16
    border.width: 1
    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: 24
    }
}
