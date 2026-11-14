// Install step: design-system/boards/Installing.dc.html.
// DOT OS's Calamares hides its own progress bar and status line when the
// slideshow is QML, and publishes them as the Execution singleton, so this
// draws the whole page: label, percentage, segmented bar with a red leading
// segment, status and time left, then the slides.
import QtQuick
import io.calamares.ui 1.0
import "components"

Rectangle {
    id: show
    color: T.surface

    readonly property real progress: Execution.progress
    readonly property int percent: Math.floor(progress * 100)

    // Time left, from the average rate so far. Shown once there is enough
    // to go on, and never counting up.
    property double started: 0
    property int minutesLeft: -1
    onProgressChanged: {
        if (started === 0 || progress <= 0) return;
        var elapsed = (Date.now() - started) / 1000;
        if (progress < 0.08 || elapsed < 30) return;
        var left = Math.max(1, Math.ceil(elapsed * (1 - progress) / progress / 60));
        if (minutesLeft < 0 || left < minutesLeft) minutesLeft = left;
    }

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

    Item {
        anchors.fill: parent
        anchors.leftMargin: T.padX
        anchors.rightMargin: T.padX
        anchors.topMargin: T.padY
        anchors.bottomMargin: T.padY

        Column {
            width: parent.width

            DLabel { text: "Installing DOT OS" }
            Item { width: 1; height: 16 }

            // .nil-unit: top-aligned beside the number.
            Row {
                spacing: 4
                DDisplay {
                    id: big
                    size: 144
                    text: show.percent
                }
                // Top of the sign level with the top of the digits, from the
                // drawn glyphs: Doto's declared cap height is taller than
                // its dots.
                TextMetrics { id: bigInk; font: big.font; text: "0" }
                TextMetrics { id: unitInk; font: unit.font; text: "%" }
                Text {
                    id: unit
                    y: big.baselineOffset + bigInk.tightBoundingRect.y
                       - (baselineOffset + unitInk.tightBoundingRect.y)
                    text: "%"
                    font.family: T.mono
                    font.pixelSize: 16
                    font.letterSpacing: 16 * 0.08
                    color: T.textSecondary
                }
            }
            Item { width: 1; height: 32 }

            // 20 segments; the leading lit one is the live mark.
            DSeg {
                width: parent.width
                height: 16
                count: 20
                lit: Math.max(1, Math.ceil(show.progress * 20))
                live: true
            }
            Item { width: 1; height: 8 }
            Item {
                width: parent.width
                height: status.height
                Text {
                    id: status
                    width: parent.width - left.width - 24
                    elide: Text.ElideRight
                    text: "[" + (Execution.message !== "" ? Execution.message : "Starting") + "]"
                    font.family: T.mono
                    font.pixelSize: 12
                    font.letterSpacing: 12 * 0.04
                    font.capitalization: Font.AllUppercase
                    color: T.textSecondary
                }
                Text {
                    id: left
                    anchors.right: parent.right
                    text: show.minutesLeft < 0 ? ""
                        : show.minutesLeft === 1 ? "About 1 min left"
                        : "About " + show.minutesLeft + " min left"
                    font.family: T.sans
                    font.pixelSize: 12
                    color: T.textSecondary
                }
            }
        }

        // Slides at the foot, counter at the right.
        Item {
            width: parent.width
            height: slide.height
            anchors.bottom: parent.bottom

            Column {
                id: slide
                width: Math.min(T.colLeft, parent.width - 96)
                spacing: 8
                DHeading { width: parent.width; text: show.slides[show.current].title }
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

    function onActivate() {
        current = 0;
        started = Date.now();
        minutesLeft = -1;
        timer.start();
    }
    function onLeave() { timer.stop(); }
}
