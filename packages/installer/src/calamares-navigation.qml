// Footer (boards/Installer*.dc.html): ghost actions on the left, Back
// (secondary) and Next (primary) on the right, 1px rule above.
//
// Calamares caps a QML navigation bar at 64px, so the 44px buttons get 10px
// above and below rather than the board's 16px.
import QtQuick
import io.calamares.ui 1.0
import "components"

Rectangle {
    id: nav
    color: T.surface
    implicitHeight: 64
    height: 64

    readonly property int step: ViewManager.currentStepIndex
    readonly property bool first: step === 0
    readonly property bool last: step === ViewManager.rowCount() - 1
    readonly property bool installing: step === ViewManager.rowCount() - 2
    readonly property string releaseNotes: Branding.string(Branding.ReleaseNotesUrl)

    Rectangle { width: parent.width; height: 1; color: T.border }

    Row {
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        DButton {
            kind: "ghost"
            visible: ViewManager.quitVisible && !nav.last
            enabled: ViewManager.quitEnabled
            text: nav.first ? "Quit" : T.plain(ViewManager.quitLabel)
            onClicked: ViewManager.quit()
        }
        DButton {
            kind: "ghost"
            visible: nav.first && nav.releaseNotes !== ""
            text: "Release notes"
            onClicked: Qt.openUrlExternally(nav.releaseNotes)
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Steps up to and including the install.
        DButton {
            kind: "secondary"
            visible: !nav.last
            enabled: ViewManager.backEnabled
            text: T.plain(ViewManager.backLabel)
            onClicked: ViewManager.back()
        }
        DButton {
            kind: nav.installing ? "secondary" : "primary"
            visible: !nav.last
            enabled: ViewManager.nextEnabled
            text: T.plain(ViewManager.nextLabel)
            onClicked: ViewManager.next()
        }

        // Finish. Both buttons close Calamares; finishedq.qml reads which one
        // was pressed from ViewManager.panelSides (only read at start-up, so
        // free to carry this) and sets the restart flag before Calamares acts
        // on it while quitting.
        DButton {
            kind: "secondary"
            visible: nav.last
            text: "Stay in live session"
            onClicked: { ViewManager.panelSides = Qt.Horizontal; ViewManager.quit(); }
        }
        DButton {
            kind: "primary"
            visible: nav.last
            text: "Restart"
            onClicked: { ViewManager.panelSides = Qt.Vertical; ViewManager.quit(); }
        }
    }
}
