// Finish step: design-system/boards/InstallFinish.dc.html.
import QtQuick
import io.calamares.core 1.0
import io.calamares.ui 1.0
import "components"

DPage {
    id: page

    // Global storage is not observable from QML; read it when the step opens.
    property string disk: ""
    property string rootFs: ""
    property string bootText: ""
    property string account: ""
    property string hostName: ""
    property string taken: ""

    Column {
        width: parent.width
        DStatus {
            kind: config.failed ? "bad" : "good"
            text: config.failed ? "[ ERROR ] Not installed" : "[ OK ] Installed"
        }
        Item { width: 1; height: 16 }
        DDisplay { text: config.failed ? "Error" : "Done" }
        Item { width: 1; height: 24 }
        DBody {
            sub: true
            width: parent.width
            text: config.failed ? "The install did not finish."
                : page.disk !== "" ? "DOT OS is on " + page.disk + "." : "DOT OS is installed."
        }
        Item { width: 1; height: 8 }
        DBody {
            width: parent.width
            textFormat: config.failed ? Text.StyledText : Text.PlainText
            text: config.failed ? config.failureMessage
                : "Restart to use it. Remove the install disk when the screen goes black."
        }
    }

    aside: Column {
        width: parent.width
        visible: !config.failed
        DLabel { text: "Summary"; bottomPadding: 4 }
        DRow { label: "Time taken"; value: page.taken; visible: page.taken !== "" }
        DRow {
            label: "Disk"
            value: [page.disk, page.rootFs].filter(function (s) { return s; }).join(", ")
            visible: value !== ""
        }
        DRow { label: "Boot"; value: page.bootText }
        DRow { label: "Account"; value: page.account }
        DRow { label: "Computer name"; value: page.hostName; last: true }
        Item { width: 1; height: 24 }
        Text {
            text: "Log saved to /var/log/installation.log"
            font.family: T.mono
            font.pixelSize: 12
            font.letterSpacing: 12 * 0.04
            color: T.textSecondary
        }
    }

    // Start the clock when the install step comes up (Global is read-only
    // from QML, so the time is kept here).
    property double started: 0
    Connections {
        target: ViewManager
        function onCurrentStepChanged() {
            if (ViewManager.currentStepIndex === ViewManager.rowCount() - 2 && page.started === 0)
                page.started = Date.now();
        }
    }

    function partitionAt(mount) {
        var parts = Global.value("partitions") || [];
        for (var i = 0; i < parts.length; i++)
            if (parts[i].mountPoint === mount) return parts[i];
        return null;
    }

    // The footer's two buttons both quit; it leaves which one in
    // ViewManager.panelSides (see calamares-navigation.qml). Calamares acts on
    // config.restartNowWanted while quitting, after this handler.
    Connections {
        target: Qt.application
        function onAboutToQuit() {
            if (ViewManager.panelSides === Qt.Vertical) config.restartNowWanted = true;
            else if (ViewManager.panelSides === Qt.Horizontal) config.restartNowWanted = false;
        }
    }

    function onActivate() {
        var boot = Global.value("bootLoader");
        disk = boot && boot.installPath ? boot.installPath : "";
        var root = partitionAt("/");
        rootFs = root && root.fs ? root.fs : "";
        bootText = Global.value("firmwareType") === "efi" ? "UEFI, grub-efi-arm64" : "GRUB";
        account = Global.value("username") || "";
        hostName = Global.value("hostname") || "";
        if (started > 0) {
            var s = Math.round((Date.now() - started) / 1000);
            taken = Math.floor(s / 60) + " min " + ("0" + s % 60).slice(-2) + " s";
        }
    }
    function onLeave() {}
}
