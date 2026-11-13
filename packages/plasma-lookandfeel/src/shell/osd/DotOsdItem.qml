// A surface pill: three-letter label, twenty segments, the number.
import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    property int timeout: 1500
    property var osdValue
    property int osdMaxValue: 100
    property string osdAdditionalText: ""
    property string icon
    property bool showingProgress: false

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Button
    readonly property color cText: Kirigami.Theme.textColor

    readonly property string label: {
        var i = root.icon || "";
        if (i.indexOf("microphone") !== -1) return "MIC";
        if (i.indexOf("audio") !== -1 || i.indexOf("volume") !== -1) return "VOL";
        if (i.indexOf("keyboard-brightness") !== -1) return "KBD";
        if (i.indexOf("brightness") !== -1) return "BRI";
        if (i.indexOf("keyboard") !== -1 || i.indexOf("input") !== -1) return "KEY";
        if (i.indexOf("battery") !== -1 || i.indexOf("power") !== -1) return "PWR";
        if (i.indexOf("touchpad") !== -1) return "PAD";
        return "";
    }
    readonly property real fraction: showingProgress && osdMaxValue > 0
        ? Math.max(0, Math.min(1, Number(osdValue) / osdMaxValue)) : 0
    readonly property string message: showingProgress ? osdAdditionalText : (osdValue !== undefined ? String(osdValue) : "")

    implicitWidth: showingProgress ? 336 : Math.max(160, row.implicitWidth + 48)
    implicitHeight: 44
    width: implicitWidth
    height: implicitHeight
    radius: height / 2
    color: Kirigami.Theme.backgroundColor
    border.width: 1
    border.color: Qt.rgba(cText.r, cText.g, cText.b, 0.2)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 16
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
            text: root.label
            color: Kirigami.Theme.disabledTextColor
            font.family: "Space Mono"; font.pixelSize: 11; font.letterSpacing: 0.88
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showingProgress
            spacing: 2
            Repeater {
                model: 20
                Rectangle {
                    width: 9; height: 4
                    color: index < Math.round(root.fraction * 20) ? Kirigami.Theme.highlightColor
                         : Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.2)
                }
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showingProgress
            width: 24
            horizontalAlignment: Text.AlignRight
            text: Math.round(Number(root.osdValue))
            color: Kirigami.Theme.highlightColor
            font.family: "Space Mono"; font.pixelSize: 12
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
            text: root.message.toUpperCase()
            color: Kirigami.Theme.textColor
            font.family: "Space Mono"; font.pixelSize: 12; font.letterSpacing: 0.48
        }
    }
}
