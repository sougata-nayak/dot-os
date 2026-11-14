// Summary step. No board of its own; built from the Installer board's parts:
// heading on the left, the plan as list rows on the right.
import QtQuick
import io.calamares.core 1.0
import io.calamares.ui 1.0
import "components"

DPage {
    id: page

    Column {
        width: parent.width
        spacing: 8
        DHeading { width: parent.width; text: "Ready to install" }
        DBody {
            width: parent.width
            text: "Check the plan. Nothing on the disk changes until you select Install."
        }
    }

    aside: Flickable {
        id: plan
        width: parent.width
        height: parent.height
        contentHeight: rows.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: rows
            width: parent.width
            DLabel { text: "Plan"; bottomPadding: 4 }
            Repeater {
                model: config.summaryModel
                Item {
                    width: rows.width
                    height: body.height + 24
                    DLabel { id: head; y: 14; width: 128; text: model.title; wrapMode: Text.WordWrap }
                    Text {
                        id: body
                        x: 144
                        y: 12
                        width: parent.width - x
                        text: model.message
                        textFormat: Text.StyledText
                        wrapMode: Text.WordWrap
                        font.family: T.sans
                        font.pixelSize: 14
                        lineHeight: 1.5
                        color: T.textPrimary
                        linkColor: T.textDisplay
                    }
                    Rectangle {
                        visible: index < config.summaryModel.rowCount() - 1
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: T.border
                    }
                }
            }
        }
        // The plan often runs past the page: fade the last rows out while
        // there is more to scroll to.
        Rectangle {
            parent: plan
            visible: plan.contentHeight > plan.height && !plan.atYEnd
            anchors.bottom: parent.bottom
            width: parent.width
            height: 96
            gradient: Gradient {
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 1; color: T.surface }
            }
        }
    }

    function onActivate() {}
    function onLeave() {}
}
