// Install step, upper part: design-system/boards/Installing.dc.html.
// Calamares draws the progress bar and status line under this view (styled
// in stylesheet.qss); this shows the step label and the slides. Text starts at
// the view's left edge, where Qt puts the percentage (see stylesheet.qss).
import QtQuick
import io.calamares.ui 1.0
import "components"

Rectangle {
    id: show
    color: T.surface

    property int current: 0
    readonly property var slides: [
        { title: "Red means live",
          body: "A small red mark shows where things are happening: the caret, today, the step in progress. Red with a message means it needs you." },
        { title: "On the grid",
          body: "Type, icons and spacing sit on a 16-pixel dot grid, from the boot screen to the desktop." },
        { title: "Built on Debian",
          body: "DOT OS is Debian 13 with KDE Plasma. Debian packages, security updates and apt work as they always do." },
        { title: "Numbers in mono",
          body: "Clocks, sizes and percentages are set in a monospaced face, so they stay put as they change." },
        { title: "Light or dark",
          body: "Both themes ship. Switch in System Settings, under Colors & Themes." }
    ]

    DLabel {
        x: 0
        y: T.padY
        text: "Installing DOT OS"
    }

    Item {
        x: 0
        width: parent.width - T.padX
        height: slide.height
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32

        Column {
            id: slide
            width: Math.min(T.colLeft, parent.width - 96)
            spacing: 8
            opacity: 1
            DHeading { id: title; width: parent.width; text: show.slides[show.current].title }
            DBody {
                width: parent.width
                font.pixelSize: 16
                text: show.slides[show.current].body
            }
        }
        DLabel {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: (show.current + 1) + " / " + show.slides.length
        }
    }

    // Fade only, 200ms, the system easing.
    SequentialAnimation {
        id: turn
        NumberAnimation { target: slide; property: "opacity"; to: 0; duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.25, 0.1, 0.25, 1, 1, 1] }
        ScriptAction { script: show.current = (show.current + 1) % show.slides.length }
        NumberAnimation { target: slide; property: "opacity"; to: 1; duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.25, 0.1, 0.25, 1, 1, 1] }
    }
    Timer {
        id: timer
        interval: 12000
        repeat: true
        onTriggered: turn.start()
    }

    function onActivate() { current = 0; timer.start(); }
    function onLeave() { timer.stop(); }
}
