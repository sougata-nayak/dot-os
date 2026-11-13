// DOT OS session splash. Layout: design-system/boards/Splash.dc.html.
// Same wordmark, in the same place, as the boot splash, over six segments:
// one per KSplash stage. The leading segment is the live marker.
import QtQuick

Rectangle {
    id: root
    color: "@black@"
    property int stage: 0

    Column {
        x: 32
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        width: 318
        spacing: 8

        Item {
            width: parent.width
            height: 72 + 24
            FontMetrics { id: fm; font.family: "Doto"; font.weight: Font.Bold; font.pixelSize: 72 }
            Text {
                y: (72 - fm.height) / 2
                text: "DOT OS"
                color: "@text-display@"
                font.family: "Doto"
                font.weight: Font.Bold
                font.pixelSize: 72
                font.letterSpacing: -2.16
            }
        }
        Row {
            spacing: 2
            Repeater {
                model: 6
                Rectangle {
                    width: (318 - 10) / 6
                    height: 16
                    color: index < root.stage - 1 ? "@text-display@"
                         : index === root.stage - 1 ? "@accent@" : "@border-visible@"
                }
            }
        }
        Item {
            width: parent.width
            height: 14
            Text {
                text: "STARTING DESKTOP"
                color: "@text-secondary@"
                font.family: "Space Mono"
                font.pixelSize: 11
                font.letterSpacing: 0.88
            }
            Text {
                anchors.right: parent.right
                text: Math.max(0, Math.min(6, root.stage)) + " / 6"
                color: "@text-display@"
                font.family: "Space Mono"
                font.pixelSize: 12
            }
        }
    }
}
