// Colours for desktop widgets, taken from the active DOT OS colour scheme so
// the dark and light themes both work.
import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    readonly property color display: Kirigami.Theme.highlightColor
    readonly property color primary: Kirigami.Theme.textColor
    readonly property color secondary: Kirigami.Theme.disabledTextColor
    readonly property color accent: Kirigami.Theme.negativeTextColor
    readonly property color line: Qt.rgba(primary.r, primary.g, primary.b, 0.2)
    readonly property color hairline: Qt.rgba(primary.r, primary.g, primary.b, 0.13)
    readonly property color empty: Qt.rgba(primary.r, primary.g, primary.b, 0.13)
}
