// CPU card. Design: the CPU widget on Main.dc.html.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

Card {
    id: root
    implicitWidth: 280
    implicitHeight: 272

    Sensors.Sensor { id: usage; sensorId: "cpu/all/usage"; updateRateLimit: 2000 }
    Sensors.Sensor { id: load; sensorId: "cpu/loadaverages/loadaverage1"; updateRateLimit: 2000 }
    Sensors.Sensor { id: temp; sensorId: "cpu/all/averageTemperature"; updateRateLimit: 5000 }

    // A sensor that is missing, or reads exactly 0 for temperature, shows a dash.
    function num(v, digits, zeroIsMissing) {
        var n = Number(v);
        return isFinite(n) && !(zeroIsMissing && n === 0) ? n.toFixed(digits) : "—";
    }

    ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Label { text: "CPU" }
            Row {
                Layout.topMargin: 12
                spacing: 4
                Text {
                    text: root.num(usage.value, 0)
                    font.family: "Space Mono"
                    font.pixelSize: 48
                    font.letterSpacing: -0.96
                    color: Kirigami.Theme.highlightColor
                }
                Label { text: "%"; anchors.top: parent.top; anchors.topMargin: 6 }
            }
            Segments {
                Layout.fillWidth: true
                Layout.topMargin: 16
                width: parent.width
                fraction: Math.max(0, Math.min(1, Number(usage.value) / 100 || 0))
                // Over 90% is the over-limit reading: accent.
                onColor: Number(usage.value) > 90 ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.highlightColor
            }
            Item { Layout.fillHeight: true }
            DataRow { Layout.fillWidth: true; label: "Load"; value: root.num(load.value, 2) }
            DataRow { Layout.fillWidth: true; label: "Temp"; value: root.num(temp.value, 0, true); unit: "°C"; last: true }
        }
}
