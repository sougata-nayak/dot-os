// The desktop clock: Doto, the colon is the live marker. Design: Main.dc.html.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    property date now: new Date()
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    fullRepresentation: Item {
        Layout.minimumWidth: col.implicitWidth
        Layout.minimumHeight: col.implicitHeight
        Layout.preferredWidth: col.implicitWidth
        Layout.preferredHeight: col.implicitHeight
        Column {
            id: col
            spacing: 8
            Item {
                width: clock.width
                height: 96
                FontMetrics { id: fm; font.family: "Doto"; font.weight: Font.Bold; font.pixelSize: 96 }
                Row {
                    id: clock
                    y: (96 - fm.height) / 2
                    Repeater {
                        model: [Qt.formatTime(root.now, "HH"), ":", Qt.formatTime(root.now, "mm")]
                        Text {
                            text: modelData
                            font.family: "Doto"
                            font.weight: Font.Bold
                            font.pixelSize: 96
                            font.letterSpacing: -2.88
                            color: modelData === ":" ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.highlightColor
                        }
                    }
                }
            }
            Label { text: Qt.locale().toString(root.now, "dddd d MMMM") }
        }
    }
}
