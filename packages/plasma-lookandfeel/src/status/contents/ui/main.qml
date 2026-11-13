// The status readout and control center. Design: the right of the top bar on
// Main.dc.html (NET, VOL, BAT) and Quick settings on Panels.dc.html.
// Each part loads on its own, so a missing module only hides that part.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: compactRepresentation
    toolTipMainText: "Control center"
    toolTipSubText: ""

    // Runs one-shot commands (open Settings, lock, power, night light).
    P5Support.DataSource {
        id: shell
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => disconnectSource(source)
    }
    function run(cmd) { shell.connectSource(cmd); }

    compactRepresentation: MouseArea {
        id: compact
        Layout.minimumWidth: readings.implicitWidth + 16
        Layout.preferredWidth: readings.implicitWidth + 16
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded
        RowLayout {
            id: readings
            anchors.centerIn: parent
            spacing: 16
            Loader { source: "Net.qml" }
            Loader { source: "Volume.qml" }
            Loader { source: "Battery.qml"; visible: item && item.present }
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 2
            color: Kirigami.Theme.highlightColor
            visible: root.expanded
        }
    }

    fullRepresentation: ControlCenter {
        onRunCommand: cmd => root.run(cmd)
        onCloseRequested: root.expanded = false
    }
}
