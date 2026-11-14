// Welcome step: design-system/boards/InstallWelcome.dc.html.
import QtQuick
import io.calamares.core 1.0
import io.calamares.ui 1.0
import "components"

DPage {
    id: page

    // Left: label, wordmark, lines; language at the foot.
    Column {
        width: parent.width
        DLabel { text: "Welcome" }
        Item { width: 1; height: 16 }
        DDisplay { text: "DOT OS" }
        Item { width: 1; height: 24 }
        DBody { sub: true; width: parent.width; text: "A quiet desktop, built on Debian and KDE Plasma." }
        Item { width: 1; height: 8 }
        DBody {
            width: parent.width
            text: "Installing takes about 10 minutes. You can keep using this live session while it runs."
        }
    }
    DField {
        width: parent.width
        anchors.bottom: parent.bottom
        label: "Language"
        DSelect {
            model: config.languagesModel
            textRole: "label"
            currentIndex: config.localeIndex
            onActivated: (i) => config.localeIndex = i
        }
    }

    aside: Column {
        width: parent.width
        DLabel { text: "This computer"; bottomPadding: 4 }

        // One row per check, in the board's order, rebuilt whenever Calamares
        // reports results (the checks run in the background).
        Repeater {
            model: page.rows
            DRow {
                label: modelData.label
                status: modelData.status
                kind: modelData.kind
                value: modelData.value
                last: index === page.rows.length - 1
            }
        }

        Item { width: 1; height: 24 }
        DBody {
            width: Math.min(parent.width, 400)
            visible: page.onBattery
            text: "Plug in before you continue. An install that loses power part-way leaves the disk unusable."
        }
        DBody {
            width: Math.min(parent.width, 400)
            visible: !config.requirementsModel.satisfiedMandatory
            color: T.textPrimary
            textFormat: Text.StyledText
            text: config.warningMessage
        }
    }

    property var rows: []
    property bool onBattery: false

    // RequirementsModel roles: Qt::UserRole + 0 name, 1 satisfied, 2 mandatory.
    function refresh() {
        var m = config.requirementsModel;
        var found = {};
        for (var i = 0; i < m.rowCount(); i++) {
            var ix = m.index(i, 0);
            found[m.data(ix, 256)] = { ok: m.data(ix, 257), mandatory: m.data(ix, 258) };
        }
        var out = [];
        var order = ["storage", "partitions", "ram", "firmware", "internet", "power", "root"];
        for (var j = 0; j < order.length; j++) {
            var id = order[j];
            var spec = id === "firmware"
                ? { label: "Firmware", status: "[ OK ]", kind: "good", value: "UEFI, arm64" }
                : found[id] ? describe(id, found[id].ok, found[id].mandatory) : null;
            if (spec) out.push(spec);
        }
        onBattery = found["power"] !== undefined && !found["power"].ok;
        rows = out;
    }
    Connections {
        target: config.requirementsModel
        function onModelReset() { page.refresh(); }
        function onSatisfiedRequirementsChanged() { page.refresh(); }
        function onSatisfiedMandatoryChanged() { page.refresh(); }
    }
    Component.onCompleted: refresh()

    // Label, status and value for each Calamares check id.
    function describe(id, ok, mandatory) {
        var mark = ok ? "[ OK ]" : mandatory ? "[ ERROR ]" : "[ WARN ]";
        var kind = ok ? "good" : mandatory ? "bad" : "warn";
        switch (id) {
        case "storage":
            return { label: "Disk space", status: mark, kind: kind, value: ok ? "needs 12 GB" : "less than 12 GB free" };
        case "partitions":
            return { label: "Install disk", status: mark, kind: kind, value: ok ? "found" : "none usable" };
        case "ram":
            return { label: "Memory", status: mark, kind: kind, value: ok ? "needs 2 GB" : "less than 2 GB" };
        case "internet":
            return { label: "Network", status: mark, kind: kind, value: ok ? "connected" : "offline, not needed" };
        case "power":
            return { label: "Power", status: mark, kind: kind, value: ok ? "on mains" : "on battery" };
        case "root":
            if (ok) return null;
            return { label: "Permissions", status: mark, kind: kind, value: "not running as root" };
        }
        return null;
    }

    function onActivate() { refresh(); }
    function onLeave() {}
}
