// DOT OS power screen. Layout: design-system/boards/Logout.dc.html.
// Countdown top-left, actions bottom-left, on black.
import QtQuick
import org.kde.plasma.private.sessions
import "timer.js" as AutoTriggerTimer

Item {
    id: root
    height: screenGeometry.height
    width: screenGeometry.width

    signal logoutRequested()
    signal haltRequested()
    signal haltUpdateRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal rebootUpdateRequested()
    signal cancelRequested()
    signal lockScreenRequested()
    signal cancelSoftwareUpdateRequested()

    property alias backgroundColor: ground.color
    property real timeout: 30
    property real remainingTime: root.timeout
    readonly property bool showAllOptions: sdtype === ShutdownType.ShutdownTypeDefault
    readonly property int pad: 32

    function sleepRequested() { root.suspendRequested(2); }
    function hibernateRequested() { root.suspendRequested(4); }

    property var currentAction: {
        switch (sdtype) {
        case ShutdownType.ShutdownTypeReboot:
            return () => softwareUpdatePending ? rebootUpdateRequested() : rebootRequested();
        case ShutdownType.ShutdownTypeHalt:
            return () => softwareUpdatePending ? haltUpdateRequested() : haltRequested();
        default:
            return () => logoutRequested();
        }
    }
    readonly property string actionLabel: sdtype === ShutdownType.ShutdownTypeReboot ? "Restarting in"
        : sdtype === ShutdownType.ShutdownTypeHalt ? "Shutting down in" : "Logging out in"

    onRemainingTimeChanged: if (remainingTime <= 0) (currentAction)()

    Timer {
        id: countDownTimer
        running: !root.showAllOptions
        repeat: true
        interval: 1000
        onTriggered: root.remainingTime--
        Component.onCompleted: AutoTriggerTimer.addCancelAutoTriggerCallback(function () {
            countDownTimer.running = false;
        })
    }

    Rectangle {
        id: ground
        anchors.fill: parent
        color: "@black@"
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelRequested()
    }
    focus: true
    Keys.onEscapePressed: root.cancelRequested()

    component Label: Text {
        font.family: "Space Mono"
        font.pixelSize: 11
        font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        color: "@text-secondary@"
    }

    component PillButton: Item {
        id: pill
        property alias text: pillText.text
        property bool primary: false
        property bool ghost: false
        signal clicked()
        implicitWidth: pillText.implicitWidth + (ghost ? 16 : 48)
        implicitHeight: 44
        activeFocusOnTab: true
        Keys.onReturnPressed: pill.clicked()
        Keys.onEnterPressed: pill.clicked()
        Keys.onSpacePressed: pill.clicked()
        Rectangle {
            anchors.fill: parent
            visible: !pill.ghost
            radius: height / 2
            color: pill.primary ? "@text-display@" : "transparent"
            border.width: pill.primary ? 0 : 1
            border.color: pillMouse.containsMouse ? "@text-primary@" : "@border-visible@"
            opacity: pill.primary && pillMouse.containsMouse ? 0.85 : 1
        }
        Rectangle {
            visible: pill.activeFocus
            anchors.fill: parent
            anchors.margins: -4
            radius: height / 2
            color: "transparent"
            border.width: 2
            border.color: "@text-display@"
        }
        Text {
            id: pillText
            anchors.centerIn: parent
            font.family: "Space Mono"
            font.pixelSize: 13
            font.letterSpacing: 0.78
            font.capitalization: Font.AllUppercase
            color: pill.primary ? "@black@"
                 : pill.ghost ? (pillMouse.containsMouse || pill.activeFocus ? "@text-display@" : "@text-secondary@")
                 : "@text-primary@"
        }
        MouseArea { id: pillMouse; anchors.fill: parent; hoverEnabled: true; onClicked: pill.clicked() }
    }

    // ---- Countdown, or the clock when all options are shown ----
    Column {
        x: root.pad
        y: root.pad
        spacing: 8
        Label { text: root.showAllOptions ? "Leave" : root.actionLabel }
        Item {
            width: heroRow.width
            height: 96
            FontMetrics { id: heroMetrics; font.family: "Doto"; font.weight: Font.Bold; font.pixelSize: 96 }
            Row {
                id: heroRow
                y: (96 - heroMetrics.height) / 2
                spacing: 4
                property date now: new Date()
                Timer { interval: 1000; running: root.showAllOptions; repeat: true; onTriggered: heroRow.now = new Date() }
                Text {
                    text: root.showAllOptions ? Qt.formatTime(heroRow.now, "hh:mm") : Math.max(0, Math.round(root.remainingTime))
                    font.family: "Doto"
                    font.weight: Font.Bold
                    font.pixelSize: 96
                    font.letterSpacing: -2.88
                    color: "@text-display@"
                }
                Text {
                    visible: !root.showAllOptions
                    y: heroMetrics.height * 0.18
                    text: "S"
                    font.family: "Space Mono"
                    font.pixelSize: 16
                    color: "@text-secondary@"
                }
            }
        }
    }

    // ---- Actions ----
    Row {
        x: root.pad
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.pad
        spacing: 16

        PillButton {
            visible: maysd && (sdtype === ShutdownType.ShutdownTypeHalt || root.showAllOptions)
            primary: true
            focus: sdtype === ShutdownType.ShutdownTypeHalt || root.showAllOptions
            text: root.showAllOptions ? "Shut down" : "Shut down now"
            onClicked: softwareUpdatePending ? root.haltUpdateRequested() : root.haltRequested()
        }
        PillButton {
            visible: maysd && (sdtype === ShutdownType.ShutdownTypeReboot || root.showAllOptions)
            primary: sdtype === ShutdownType.ShutdownTypeReboot
            focus: sdtype === ShutdownType.ShutdownTypeReboot
            text: root.showAllOptions ? "Restart" : "Restart now"
            onClicked: softwareUpdatePending ? root.rebootUpdateRequested() : root.rebootRequested()
        }
        PillButton {
            visible: spdMethods.SuspendState && root.showAllOptions
            text: "Sleep"
            onClicked: root.sleepRequested()
        }
        PillButton {
            visible: canLogout && (sdtype === ShutdownType.ShutdownTypeNone || root.showAllOptions)
            primary: sdtype === ShutdownType.ShutdownTypeNone
            focus: sdtype === ShutdownType.ShutdownTypeNone
            text: root.showAllOptions ? "Log out" : "Log out now"
            onClicked: root.logoutRequested()
        }
        PillButton {
            ghost: true
            text: "Cancel"
            onClicked: root.cancelRequested()
        }
    }
}
