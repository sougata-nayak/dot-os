// DOT OS on-screen display for volume, brightness and layout keys.
// Installed over Plasma's own Osd.qml with dpkg-divert. Design: the OSD on
// design-system/boards/Switcher.dc.html.
import QtQuick
import org.kde.plasma.core as PlasmaCore

PlasmaCore.Dialog {
    location: PlasmaCore.Types.Floating
    type: PlasmaCore.Dialog.OnScreenDisplay
    outputOnly: true
    backgroundHints: PlasmaCore.Dialog.NoBackground

    property alias timeout: osd.timeout
    property alias osdValue: osd.osdValue
    property alias osdMaxValue: osd.osdMaxValue
    property alias osdAdditionalText: osd.osdAdditionalText
    property alias icon: osd.icon
    property alias showingProgress: osd.showingProgress

    mainItem: DotOsdItem { id: osd }
}
