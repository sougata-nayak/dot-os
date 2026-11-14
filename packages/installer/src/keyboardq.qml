// Keyboard step. No board of its own; the Installer board's grammar: pickers
// on the left, the result on the right. (No live test field: Calamares
// runs as root and cannot switch the live session's KWin layout on Wayland.)
import QtQuick
import io.calamares.core 1.0
import io.calamares.ui 1.0
import "components"

DPage {
    id: page

    Column {
        width: parent.width
        spacing: 24

        Column {
            width: parent.width
            spacing: 8
            DHeading { width: parent.width; text: "Choose a keyboard" }
            DBody { width: parent.width; text: "Pick the layout printed on your keys. You can add more later in System Settings." }
        }

        DField {
            width: parent.width
            label: "Layout"
            DSelect {
                model: config.keyboardLayoutsModel
                textRole: "label"
                currentIndex: model.currentIndex
                onActivated: (i) => model.currentIndex = i
            }
        }
        DField {
            width: parent.width
            label: "Variant"
            DSelect {
                model: config.keyboardVariantsModel
                textRole: "label"
                currentIndex: model.currentIndex
                onActivated: (i) => model.currentIndex = i
            }
        }
        DField {
            width: parent.width
            label: "Keyboard model"
            DSelect {
                model: config.keyboardModelsModel
                textRole: "label"
                currentIndex: model.currentIndex
                onActivated: (i) => model.currentIndex = i
            }
        }
    }

    aside: Column {
        width: parent.width
        spacing: 24
        Column {
            width: parent.width
            topPadding: 76
            DLabel { text: "You get"; bottomPadding: 4 }
            DBody {
                width: parent.width
                topPadding: 12
                color: T.textPrimary
                textFormat: Text.StyledText
                text: config.prettyStatus
            }
        }
    }

    function onActivate() {}
    function onLeave() {}
}
