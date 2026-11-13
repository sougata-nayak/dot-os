import QtQuick
import org.kde.kirigami as Kirigami

Row {
    property alias label: l.text
    property alias value: v.text
    property bool alert: false
    spacing: 6
    Text {
        id: l
        font.family: "Space Mono"; font.pixelSize: 11; font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        color: Kirigami.Theme.disabledTextColor
    }
    Text {
        id: v
        font.family: "Space Mono"; font.pixelSize: 11; font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        color: alert ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
    }
}
