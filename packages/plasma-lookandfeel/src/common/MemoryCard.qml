// Memory card. Design: the Memory widget on Main.dc.html.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

Card {
    id: root
    implicitWidth: 280
    implicitHeight: 168

    Sensors.Sensor { id: used; sensorId: "memory/physical/used"; updateRateLimit: 2000 }
    Sensors.Sensor { id: total; sensorId: "memory/physical/total"; updateRateLimit: 10000 }
    readonly property real gib: 1024 * 1024 * 1024
    readonly property real fraction: Number(total.value) > 0 ? Number(used.value) / Number(total.value) : 0

    ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Label { text: "Memory" }
            Row {
                Layout.topMargin: 12
                spacing: 4
                Text {
                    text: isFinite(Number(used.value)) ? (Number(used.value) / root.gib).toFixed(1) : "—"
                    font.family: "Space Mono"
                    font.pixelSize: 48
                    font.letterSpacing: -0.96
                    color: Kirigami.Theme.highlightColor
                }
                Label {
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    text: "/ " + (isFinite(Number(total.value)) ? Math.round(Number(total.value) / root.gib) : "—") + " GB"
                }
            }
            Item { Layout.fillHeight: true }
            Segments {
                Layout.fillWidth: true
                width: parent.width
                fraction: root.fraction
                onColor: root.fraction > 0.9 ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.highlightColor
            }
        }
}
