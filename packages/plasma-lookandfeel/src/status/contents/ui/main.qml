// Top-bar status as instrument labels: "NET ON   VOL 62   BAT 84%".
// Design: the right of the top bar on Main.dc.html. Each reading loads on its
// own, so a missing module only hides that reading.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    fullRepresentation: RowLayout {
        spacing: 16
        Layout.minimumWidth: implicitWidth + 8
        Layout.preferredWidth: implicitWidth + 8
        Loader { source: "Net.qml"; Layout.alignment: Qt.AlignVCenter }
        Loader { source: "Volume.qml"; Layout.alignment: Qt.AlignVCenter }
        Loader { source: "Battery.qml"; Layout.alignment: Qt.AlignVCenter; visible: item && item.present }
    }
}
