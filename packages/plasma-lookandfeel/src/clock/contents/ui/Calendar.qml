// The calendar popup. Design: the calendar on Panels.dc.html.
// Today is the live marker: an accent disc with white numerals.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: view
    property date today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()
    implicitWidth: 320
    implicitHeight: col.implicitHeight + 32

    readonly property color cText: Kirigami.Theme.textColor
    readonly property color cDim: Kirigami.Theme.disabledTextColor
    readonly property color cOff: Qt.rgba(cText.r, cText.g, cText.b, 0.4)
    readonly property int firstDay: Qt.locale().firstDayOfWeek % 7   // 0 = Sunday

    function isoWeek(d) {
        var t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        var day = t.getUTCDay() || 7;
        t.setUTCDate(t.getUTCDate() + 4 - day);
        var y0 = new Date(Date.UTC(t.getUTCFullYear(), 0, 1));
        return Math.ceil(((t - y0) / 86400000 + 1) / 7);
    }
    function cellDate(i) {
        var first = new Date(view.year, view.month, 1);
        var lead = (first.getDay() - view.firstDay + 7) % 7;
        return new Date(view.year, view.month, 1 - lead + i);
    }
    function shift(n) {
        var d = new Date(view.year, view.month + n, 1);
        view.year = d.getFullYear();
        view.month = d.getMonth();
    }

    component Label: Text {
        font.family: "Space Mono"; font.pixelSize: 11; font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        color: view.cDim
    }

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 4
                Label { text: Qt.locale().toString(view.today, "dddd") }
                Item {
                    implicitWidth: dayText.implicitWidth
                    implicitHeight: 48
                    FontMetrics { id: fm; font.family: "Doto"; font.weight: Font.Bold; font.pixelSize: 48 }
                    Text {
                        id: dayText
                        y: (48 - fm.height) / 2
                        text: view.today.getDate()
                        font.family: "Doto"; font.weight: Font.Bold; font.pixelSize: 48
                        color: Kirigami.Theme.highlightColor
                    }
                }
            }
            Item { Layout.fillWidth: true }
            ColumnLayout {
                spacing: 4
                Layout.alignment: Qt.AlignBottom
                Label {
                    Layout.alignment: Qt.AlignRight
                    text: Qt.locale().toString(new Date(view.year, view.month, 1), "MMMM yyyy")
                    color: view.cText
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 12
                    Label {
                        text: "‹"
                        font.pixelSize: 14
                        MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: view.shift(-1) }
                    }
                    Label { text: "Week " + view.isoWeek(view.today) }
                    Label {
                        text: "›"
                        font.pixelSize: 14
                        MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: view.shift(1) }
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 0
            Repeater {
                model: 7
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.locale().dayName((view.firstDay + index) % 7, Locale.NarrowFormat)
                }
            }
            Repeater {
                model: 42
                Item {
                    readonly property date d: view.cellDate(index)
                    readonly property bool inMonth: d.getMonth() === view.month
                    readonly property bool isToday: d.toDateString() === view.today.toDateString()
                    visible: index < 35 || view.cellDate(35).getMonth() === view.month
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Rectangle {
                        anchors.centerIn: parent
                        width: 36; height: 36; radius: 18
                        color: Kirigami.Theme.negativeTextColor
                        visible: parent.isToday
                    }
                    Text {
                        anchors.centerIn: parent
                        text: parent.d.getDate()
                        font.family: "Space Mono"; font.pixelSize: 13
                        color: parent.isToday ? "#FFFFFF" : parent.inMonth ? view.cText : view.cOff
                    }
                }
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => view.shift(wheel.angleDelta.y > 0 ? -1 : 1)
    }
}
