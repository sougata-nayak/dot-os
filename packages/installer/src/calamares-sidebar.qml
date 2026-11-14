// Step list (boards/Installer*.dc.html, nav "Install steps"): mono 12px
// uppercase; the current step in [ brackets ], done steps secondary, steps
// still to come disabled. Step count and version sit at the foot.
import QtQuick
import io.calamares.ui 1.0
import "components"

Rectangle {
    id: side
    color: T.surface

    TextMetrics { id: ch; font.family: T.mono; font.pixelSize: 12; text: "00" }

    Column {
        x: 24
        y: 32
        width: parent.width - 48
        spacing: 16
        Repeater {
            id: steps
            model: ViewManager
            Text {
                readonly property bool current: index === ViewManager.currentStepIndex
                width: parent.width
                text: current ? "[ " + T.stepName(display) + " ]" : T.stepName(display)
                leftPadding: current ? 0 : ch.advanceWidth + 2 * 12 * 0.08
                elide: Text.ElideRight
                font.family: T.mono
                font.pixelSize: 12
                font.letterSpacing: 12 * 0.08
                font.capitalization: Font.AllUppercase
                color: current ? T.textDisplay
                     : index < ViewManager.currentStepIndex ? T.textSecondary
                     : T.textDisabled
            }
        }
    }

    DLabel {
        x: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        lineHeight: 1.8
        text: "Step " + (ViewManager.currentStepIndex + 1) + " / " + steps.count + "\nv" + T.version + " arm64"
    }

    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: T.border
    }
}
