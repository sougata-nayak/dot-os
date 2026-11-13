// Quick settings: four tiles, three meters, three actions.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: cc
    signal runCommand(string cmd)
    signal closeRequested()

    implicitWidth: 320
    implicitHeight: col.implicitHeight + 32
    Layout.minimumWidth: 320
    Layout.preferredWidth: 320
    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight

    readonly property color cText: Kirigami.Theme.textColor
    readonly property color cDisplay: Kirigami.Theme.highlightColor
    readonly property color cSecondary: Kirigami.Theme.disabledTextColor
    readonly property color cLine: Qt.rgba(cText.r, cText.g, cText.b, 0.2)
    readonly property color cHair: Qt.rgba(cText.r, cText.g, cText.b, 0.13)

    component Label: Text {
        font.family: "Space Mono"; font.pixelSize: 11; font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        color: cc.cSecondary
    }

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
        spacing: 16

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 8
            Loader { Layout.fillWidth: true; Layout.preferredHeight: 72; source: "WifiTile.qml" }
            Loader { Layout.fillWidth: true; Layout.preferredHeight: 72; source: "BluetoothTile.qml" }
            Loader {
                Layout.fillWidth: true; Layout.preferredHeight: 72; source: "NightLightTile.qml"
                onLoaded: item.runCommand.connect(cc.runCommand)
            }
            Loader { Layout.fillWidth: true; Layout.preferredHeight: 72; source: "DndTile.qml" }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            Loader { Layout.fillWidth: true; source: "BrightnessMeter.qml"; visible: item && item.available }
            Loader { Layout.fillWidth: true; source: "VolumeMeter.qml" }
            Loader { Layout.fillWidth: true; source: "BatteryMeter.qml"; visible: item && item.present }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: cc.cHair }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: [
                    { label: "Settings", cmd: "systemsettings" },
                    { label: "Lock", cmd: "loginctl lock-session" },
                    { label: "Power", cmd: "qdbus6 org.kde.LogoutPrompt /LogoutPrompt promptAll" }
                ]
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.family: "Space Mono"; font.pixelSize: 13; font.letterSpacing: 0.78
                        font.capitalization: Font.AllUppercase
                        color: area.containsMouse ? cc.cDisplay : cc.cSecondary
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { cc.closeRequested(); cc.runCommand(modelData.cmd); }
                    }
                }
            }
        }
    }
}
