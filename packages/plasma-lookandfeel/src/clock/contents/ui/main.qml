// DOT OS clock: "THU 12 NOV  09:41" in the bar; a month calendar on click.
// Design: the top bar on design-system/boards/Main.dc.html and the calendar
// on Panels.dc.html.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation

    property date now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var d = new Date();
            if (d.getMinutes() !== root.now.getMinutes() || d.getDate() !== root.now.getDate()) {
                root.now = d;
            }
        }
    }
    readonly property string barText: Qt.locale().toString(root.now, "ddd d MMM") + "  " + Qt.formatTime(root.now, "HH:mm")
    toolTipMainText: Qt.locale().toString(root.now, "dddd d MMMM yyyy")
    toolTipSubText: ""

    compactRepresentation: MouseArea {
        Layout.minimumWidth: label.implicitWidth + 16
        Layout.preferredWidth: label.implicitWidth + 16
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded
        Text {
            id: label
            anchors.centerIn: parent
            text: root.barText
            color: Kirigami.Theme.textColor
            font.family: "Space Mono"
            font.pixelSize: 11
            font.letterSpacing: 0.88
            font.capitalization: Font.AllUppercase
            textFormat: Text.PlainText
        }
    }

    fullRepresentation: Loader {
        Layout.minimumWidth: 320
        Layout.minimumHeight: item ? item.implicitHeight : 360
        Layout.preferredWidth: 320
        Layout.preferredHeight: item ? item.implicitHeight : 360
        // The calendar lives in its own file so the bar text still shows if
        // the calendar module is ever unavailable.
        source: "Calendar.qml"
        onLoaded: item.today = Qt.binding(() => root.now)
        onActiveChanged: if (item) { item.year = root.now.getFullYear(); item.month = root.now.getMonth(); }
    }
}
