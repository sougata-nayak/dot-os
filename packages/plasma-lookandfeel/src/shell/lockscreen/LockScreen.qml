// DOT OS lock screen. Layout: design-system/boards/Lock.dc.html.
// Installed over Plasma's own LockScreen.qml with dpkg-divert by
// dot-os-plasma-lookandfeel; removing the package restores Plasma's.
//
// Only QtQuick is imported here on purpose: if this file ever failed to
// load, kscreenlocker falls back to its built-in screen, so nobody is
// locked out. The dot grid behind is the wallpaper kscreenlocker draws.
import QtQuick

Item {
    id: root

    // Set by kscreenlocker.
    property bool locked: false
    property bool viewVisible: false
    property bool suspendToRamSupported: false
    property bool suspendToDiskSupported: false
    signal suspendToRam()
    signal suspendToDisk()

    property bool failed: false
    property string notice: ""
    readonly property int pad: 32

    onViewVisibleChanged: if (viewVisible) passwordInput.forceActiveFocus()

    Rectangle { anchors.fill: parent; z: -2000; color: "@black@" }

    function tryUnlock() {
        if (authenticator.busy) return;
        root.failed = false;
        root.notice = "";
        authenticator.startAuthenticating();
    }

    Connections {
        target: authenticator
        function onFailed(kind) {
            if (kind !== undefined && kind !== 0) return;   // fingerprint, smartcard
            root.failed = true;
            root.notice = "[Error: wrong password]";
            passwordInput.text = "";
            passwordInput.forceActiveFocus();
        }
        function onSucceeded() { Qt.quit(); }
        function onPromptForSecretChanged() { authenticator.respond(passwordInput.text); }
        function onInfoMessageChanged() {
            if (authenticator.infoMessage) { root.failed = false; root.notice = "[" + authenticator.infoMessage + "]"; }
        }
        function onErrorMessageChanged() {
            if (authenticator.errorMessage) { root.failed = true; root.notice = "[Error: " + authenticator.errorMessage + "]"; }
        }
        function onBusyChanged() { if (!authenticator.busy) passwordInput.forceActiveFocus(); }
    }

    Loader { id: capsLock; source: "DotCapsLock.qml" }
    readonly property bool capsLockOn: capsLock.status === Loader.Ready && capsLock.item.on

    component Label: Text {
        font.family: "Space Mono"; font.pixelSize: 11; font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        color: "@text-secondary@"
    }

    // ---- Clock ----
    Column {
        x: root.pad
        y: root.pad
        spacing: 8
        Item {
            width: clockRow.width
            height: 144
            FontMetrics { id: fm; font.family: "Doto"; font.weight: Font.Bold; font.pixelSize: 144 }
            Row {
                id: clockRow
                y: (144 - fm.height) / 2
                property date now: new Date()
                Timer { interval: 1000; running: true; repeat: true; onTriggered: clockRow.now = new Date() }
                Repeater {
                    model: [Qt.formatTime(clockRow.now, "HH"), ":", Qt.formatTime(clockRow.now, "mm")]
                    Text {
                        text: modelData
                        font.family: "Doto"; font.weight: Font.Bold; font.pixelSize: 144
                        font.letterSpacing: -4.32
                        color: modelData === ":" ? "@accent@" : "@text-display@"
                    }
                }
            }
        }
        Label { text: Qt.locale().toString(clockRow.now, "dddd d MMMM") }
    }

    // ---- Password ----
    Column {
        x: root.pad
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.pad
        width: 280
        spacing: 8

        Label { text: "Password — " + kscreenlocker_userName }
        Item {
            width: parent.width
            height: 32
            TextInput {
                id: passwordInput
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                focus: true
                echoMode: TextInput.Password
                passwordCharacter: "•"
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                font.family: "Space Mono"; font.pixelSize: 16
                color: "@text-primary@"
                selectionColor: "@text-display@"
                selectedTextColor: "@black@"
                clip: true
                enabled: !authenticator.busy
                onAccepted: root.tryUnlock()
                onTextEdited: { root.failed = false; root.notice = ""; }
                Keys.onEscapePressed: text = ""
                cursorDelegate: Rectangle { width: 2; color: "@accent@"; visible: passwordInput.activeFocus }
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: root.failed ? "@accent@" : "@text-display@"
            }
        }
        Row {
            spacing: 8
            height: 16
            Rectangle {
                visible: root.failed
                width: 6; height: 6; radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: "@accent@"
            }
            Text {
                text: root.notice !== "" ? root.notice
                    : authenticator.busy ? "[Checking...]"
                    : root.capsLockOn ? "[Caps lock on]" : ""
                font.family: "Space Mono"; font.pixelSize: 12; font.letterSpacing: 0.48
                font.capitalization: Font.AllUppercase
                color: "@text-secondary@"
            }
        }
    }

    // ---- Sleep, bottom-right ----
    Item {
        visible: root.suspendToRamSupported
        anchors { right: parent.right; bottom: parent.bottom; rightMargin: root.pad - 8; bottomMargin: root.pad - 14 }
        width: sleepText.implicitWidth + 16
        height: 44
        Text {
            id: sleepText
            anchors.centerIn: parent
            text: "SLEEP"
            font.family: "Space Mono"; font.pixelSize: 13; font.letterSpacing: 0.78
            color: sleepMouse.containsMouse ? "@text-display@" : "@text-secondary@"
        }
        MouseArea { id: sleepMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.suspendToRam() }
    }

    // ---- Volume and brightness keys while locked ----
    Rectangle {
        id: osd
        objectName: "onScreenDisplay"
        property var osdValue
        property int osdMaxValue: 100
        property string osdAdditionalText: ""
        property string icon
        property bool showingProgress: false
        onOsdValueChanged: { opacity = 1; osdTimer.restart(); }
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 96 }
        width: 336; height: 44; radius: 22
        color: "@surface@"
        border.width: 1
        border.color: "@border-visible@"
        opacity: 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Timer { id: osdTimer; interval: 1500; onTriggered: osd.opacity = 0 }
        Row {
            anchors.centerIn: parent
            spacing: 2
            visible: osd.showingProgress
            Repeater {
                model: 20
                Rectangle {
                    width: 12; height: 4
                    color: index < Math.round(20 * Number(osd.osdValue) / Math.max(1, osd.osdMaxValue))
                        ? "@text-display@" : "@border-visible@"
                }
            }
        }
        Text {
            anchors.centerIn: parent
            visible: !osd.showingProgress
            text: osd.osdValue !== undefined ? String(osd.osdValue).toUpperCase() : ""
            font.family: "Space Mono"; font.pixelSize: 12
            color: "@text-primary@"
        }
    }

    Component.onCompleted: passwordInput.forceActiveFocus()
}
