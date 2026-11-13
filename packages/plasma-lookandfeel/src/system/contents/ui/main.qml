// CPU and memory cards, stacked. Design: the widgets on Main.dc.html.
// One widget, so the desktop's grid snapping can never overlap the two cards.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    fullRepresentation: Column {
        spacing: 16
        Layout.minimumWidth: 280
        Layout.minimumHeight: 272 + 16 + 168
        Layout.preferredWidth: 280
        Layout.preferredHeight: 272 + 16 + 168
        CpuCard { width: 280; height: 272 }
        MemoryCard { width: 280; height: 168 }
    }
}
