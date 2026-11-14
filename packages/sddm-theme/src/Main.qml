// DOT OS login greeter. Layout: design-system/boards/Login.dc.html.
// Clock top-left, user and password bottom-left, session and power bottom-right,
// all on the dot grid. Plain QtQuick only, so it runs on any SDDM Qt 6 greeter.
// @TOKENS@ markers are filled in by build.py from design-system/tokens.json.
import QtQuick

Rectangle {
    id: root
    width: 1280
    height: 800
    color: "@black@"

    readonly property color cBorder: "@border@"
    readonly property color cBorderVisible: "@border-visible@"
    readonly property color cDisabled: "@text-disabled@"
    readonly property color cSecondary: "@text-secondary@"
    readonly property color cPrimary: "@text-primary@"
    readonly property color cDisplay: "@text-display@"
    readonly property color cAccent: "@accent@"
    readonly property color cBlack: "@black@"
    readonly property int pad: 32
    readonly property string mono: "Space Mono"
    readonly property string sans: "Space Grotesk"
    readonly property string display: "Doto"
    readonly property string osVersion: "@version@"

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool failed: false
    property bool busy: false

    // ---- Dot grid: 1px dots at 16px, the only texture ----
    // A vector tile, so it stays sharp on high-density displays.
    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        sourceSize: Qt.size(16 * root.k, 16 * root.k)
        source: "dot.svg"
        smooth: false
    }

    // SDDM starts before any session, so it often gets no scale factor even on
    // a high-density panel. When the greeter is unscaled and the panel is
    // large, everything below is laid out at half size and drawn at 2x.
    readonly property real k: Screen.devicePixelRatio >= 1.5 ? 1
        : (width >= 3800 || height >= 2100) ? 2.5
        : (width >= 2880 || height >= 1700 || (width >= 2560 && height >= 1600)) ? 2 : 1

    Item {
    id: ui
    width: root.width / root.k
    height: root.height / root.k
    scale: root.k
    transformOrigin: Item.TopLeft

    // ---- Helpers ----
    component Label: Text {
        font.family: root.mono
        font.pixelSize: 11
        font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        color: root.cSecondary
    }

    component GhostButton: Item {
        id: gb
        property alias text: gbText.text
        signal clicked()
        implicitWidth: gbText.implicitWidth + 16
        implicitHeight: 44
        activeFocusOnTab: true
        Keys.onReturnPressed: gb.clicked()
        Keys.onEnterPressed: gb.clicked()
        Keys.onSpacePressed: gb.clicked()
        Text {
            id: gbText
            anchors.centerIn: parent
            font.family: root.mono
            font.pixelSize: 13
            font.letterSpacing: 0.78
            font.capitalization: Font.AllUppercase
            color: gbMouse.containsMouse || gb.activeFocus ? root.cDisplay : root.cSecondary
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.25, 0.1, 0.25, 1, 1, 1] } }
        }
        FocusRing { visible: gb.activeFocus }
        MouseArea { id: gbMouse; anchors.fill: parent; hoverEnabled: true; onClicked: gb.clicked() }
    }

    component FocusRing: Rectangle {
        anchors.fill: parent
        anchors.margins: -4
        radius: height / 2
        color: "transparent"
        border.width: 2
        border.color: root.cDisplay
    }

    // ---- Clock and host, top ----
    Column {
        x: root.pad
        y: root.pad
        spacing: 8
        // A 96px box with the glyphs centred in it, as CSS line-height 1 does,
        // so the date sits 8px under the clock rather than under its descent.
        Item {
            width: clockRow.width
            height: 96
        FontMetrics { id: clockMetrics; font.family: root.display; font.weight: Font.Bold; font.pixelSize: 96 }
        Row {
            id: clockRow
            y: (96 - clockMetrics.height) / 2
            property date now: new Date()
            Timer { interval: 1000; running: true; repeat: true; onTriggered: clockRow.now = new Date() }
            Repeater {
                model: [Qt.formatTime(clockRow.now, "hh"), ":", Qt.formatTime(clockRow.now, "mm")]
                Text {
                    text: modelData
                    font.family: root.display
                    font.weight: Font.Bold
                    font.pixelSize: 96
                    font.letterSpacing: -2.88
                    // The colon is the clock's live marker.
                    color: modelData === ":" ? root.cAccent : root.cDisplay
                }
            }
        }
        }
        Label { text: Qt.formatDate(clockRow.now, "dddd d MMMM") }
    }

    Label {
        anchors { right: parent.right; top: parent.top; margins: root.pad }
        text: (sddm.hostName ? sddm.hostName + "   " : "") + "DOT OS " + root.osVersion
    }

    // ---- Credentials, bottom-left ----
    Column {
        id: form
        x: root.pad
        anchors { bottom: parent.bottom; bottomMargin: root.pad }
        width: 280
        spacing: 24

        Field {
            id: userField
            labelText: "User"
            // The last user, or the only one.
            input.text: userModel.lastUser !== "" ? userModel.lastUser
                        : (userNames.count === 1 && userNames.itemAt(0) ? userNames.itemAt(0).name : "")
            KeyNavigation.tab: passwordField.input
        }
        Field {
            id: passwordField
            labelText: "Password"
            input.echoMode: TextInput.Password
            input.passwordCharacter: "•"
            error: root.failed
            reserveMessage: true
            message: root.failed ? "[Error: wrong password]"
                     : (keyboard.capsLock ? "[Caps lock on]" : "")
            input.onTextEdited: root.failed = false
            input.onAccepted: ui.login()
            KeyNavigation.tab: loginButton
        }
        Row {
            spacing: 16
            Item {
                id: loginButton
                width: loginText.implicitWidth + 48
                height: 44
                activeFocusOnTab: true
                Keys.onReturnPressed: ui.login()
                Keys.onEnterPressed: ui.login()
                Keys.onSpacePressed: ui.login()
                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: root.cDisplay
                    opacity: loginMouse.containsMouse ? 0.85 : 1
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                Text {
                    id: loginText
                    anchors.centerIn: parent
                    text: root.busy ? "Logging in" : "Log in"
                    font.family: root.mono
                    font.pixelSize: 13
                    font.letterSpacing: 0.78
                    font.capitalization: Font.AllUppercase
                    color: root.cBlack
                }
                FocusRing { visible: loginButton.activeFocus }
                MouseArea { id: loginMouse; anchors.fill: parent; hoverEnabled: true; onClicked: ui.login() }
            }
            GhostButton {
                text: "Other user"
                onClicked: { userField.input.text = ""; passwordField.input.text = ""; userField.input.forceActiveFocus() }
            }
        }
    }

    // ---- Session, layout and power, bottom-right ----
    Column {
        anchors { right: parent.right; bottom: parent.bottom; margins: root.pad }
        spacing: 16

        Row {
            anchors.right: parent.right
            spacing: 24
            Cycler {
                labelText: "Session"
                valueText: sessionNames.count > 0 && sessionNames.itemAt(root.sessionIndex)
                           ? sessionNames.itemAt(root.sessionIndex).name : ""
                onClicked: root.sessionIndex = (root.sessionIndex + 1) % Math.max(1, sessionModel.rowCount())
            }
            Cycler {
                visible: keyboard.layouts.length > 0
                labelText: "Layout"
                valueText: keyboard.layouts.length > 0 ? keyboard.layouts[keyboard.currentLayout].shortName : ""
                onClicked: keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
            }
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: -8
            spacing: 8
            GhostButton { text: "Sleep"; visible: sddm.canSuspend; onClicked: sddm.suspend() }
            GhostButton { text: "Restart"; visible: sddm.canReboot; onClicked: sddm.reboot() }
            GhostButton { text: "Shut down"; visible: sddm.canPowerOff; onClicked: sddm.powerOff() }
        }
    }

    Repeater {
        id: userNames
        model: userModel
        delegate: Item { property string name: model.name }
    }

    Repeater {
        id: sessionNames
        model: sessionModel
        delegate: Item { property string name: model.name }
    }

    // ---- Behaviour ----
    // Lives on `ui` (the scaling wrapper above), so callers use ui.login().
    function login() {
        if (root.busy || userField.input.text === "") return;
        root.busy = true;
        root.failed = false;
        sddm.login(userField.input.text, passwordField.input.text, root.sessionIndex);
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false;
            root.failed = true;
            passwordField.input.text = "";
            passwordField.input.forceActiveFocus();
        }
        function onLoginSucceeded() { root.busy = false }
    }

    Component.onCompleted: {
        if (userField.input.text === "") userField.input.forceActiveFocus();
        else passwordField.input.forceActiveFocus();
    }

    // ---- Components with their own state ----
    component Field: Column {
        id: field
        property alias labelText: fieldLabel.text
        property alias input: textInput
        property bool error: false
        property string message: ""
        // Keep the message line's space so the form does not jump when an error appears.
        property bool reserveMessage: false
        width: parent ? parent.width : 280
        spacing: 8
        Label { id: fieldLabel }
        Item {
            width: parent.width
            height: 32
            TextInput {
                id: textInput
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                font.family: root.mono
                font.pixelSize: 16
                color: root.cPrimary
                selectionColor: root.cDisplay
                selectedTextColor: root.cBlack
                clip: true
                // The caret is a live marker.
                cursorDelegate: Rectangle {
                    width: 2
                    color: root.cAccent
                    visible: textInput.activeFocus
                }
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: field.error ? root.cAccent : (textInput.activeFocus ? root.cDisplay : root.cBorderVisible)
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
        Row {
            spacing: 8
            height: 16
            width: field.width
            visible: field.reserveMessage || field.message !== ""
            Rectangle {
                visible: field.error
                width: 6; height: 6; radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: root.cAccent
            }
            Text {
                text: field.message
                font.family: root.mono
                font.pixelSize: 12
                font.letterSpacing: 0.48
                font.capitalization: Font.AllUppercase
                color: root.cSecondary
            }
        }
    }

    component Cycler: Item {
        id: cy
        property alias labelText: cyLabel.text
        property alias valueText: cyValue.text
        signal clicked()
        implicitWidth: cyRow.implicitWidth
        implicitHeight: cyRow.implicitHeight
        activeFocusOnTab: true
        Keys.onReturnPressed: cy.clicked()
        Keys.onSpacePressed: cy.clicked()
        Row {
            id: cyRow
            spacing: 8
            Label { id: cyLabel }
            Label {
                id: cyValue
                color: cyMouse.containsMouse || cy.activeFocus ? root.cDisplay : root.cPrimary
            }
        }
        MouseArea { id: cyMouse; anchors.fill: parent; anchors.margins: -8; hoverEnabled: true; onClicked: cy.clicked() }
    }
    }
}
