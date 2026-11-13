// DOT OS workspaces: "[ 1 ] 2 3 4 5  TERMINAL". Design: the top bar on
// design-system/boards/Main.dc.html. The brackets are the live marker.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.private.pager
import org.kde.taskmanager as TaskManager
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation

    readonly property color cText: Kirigami.Theme.textColor
    readonly property color cDim: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    readonly property color cAccent: Kirigami.Theme.negativeTextColor

    PagerModel {
        id: pagerModel
        enabled: true
        showDesktop: false
        pagerType: PagerModel.VirtualDesktops
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortDisabled
        groupMode: TaskManager.TasksModel.GroupDisabled
        function activeAppName() {
            var name = data(activeTask, TaskManager.AbstractTasksModel.AppName);
            return name ? String(name) : "";
        }
        property string appName: ""
        onActiveTaskChanged: appName = activeAppName()
        onDataChanged: appName = activeAppName()
        onCountChanged: appName = activeAppName()
        Component.onCompleted: appName = activeAppName()
    }

    component BarText: Text {
        font.family: "Space Mono"
        font.pixelSize: 11
        font.letterSpacing: 0.88
        font.capitalization: Font.AllUppercase
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
    }

    fullRepresentation: Item {
        Layout.minimumWidth: row.implicitWidth + 16
        Layout.preferredWidth: row.implicitWidth + 16
        Layout.fillHeight: true

        Row {
            id: row
            x: 8
            height: parent.height
            spacing: 8

            Repeater {
                model: pagerModel
                Item {
                    readonly property bool current: index === pagerModel.currentPage
                    width: cell.implicitWidth
                    height: row.height
                    Row {
                        id: cell
                        height: parent.height
                        BarText { height: parent.height; visible: current; text: "[ "; color: root.cAccent }
                        BarText {
                            height: parent.height
                            text: index + 1
                            color: current || area.containsMouse ? root.cText : root.cDim
                        }
                        BarText { height: parent.height; visible: current; text: " ]"; color: root.cAccent }
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        onClicked: pagerModel.changePage(index)
                    }
                }
            }
            BarText {
                height: parent.height
                leftPadding: 8
                visible: text !== ""
                text: tasksModel.appName
                color: root.cDim
                elide: Text.ElideRight
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel => {
                var n = pagerModel.count;
                if (n < 2) return;
                var next = (pagerModel.currentPage + (wheel.angleDelta.y < 0 ? 1 : n - 1)) % n;
                pagerModel.changePage(next);
            }
        }
    }
}
