// .nil-seg: equal segments, 2px apart. `lit` segments are on; `live` turns
// the last lit one red (the step in progress). `tone` colours the lit ones:
// "" (white), good, warn, bad.
import QtQuick
import "."

Row {
    id: s
    property int count: 20
    property int lit: 0
    property bool live: false
    property string tone: ""
    property var colors: []     // optional per-segment colours (partition map)
    spacing: 2
    height: 10

    Repeater {
        model: s.count
        Rectangle {
            width: (s.width - (s.count - 1) * s.spacing) / s.count
            height: s.height
            color: s.colors.length > index && s.colors[index] ? s.colors[index]
                 : index >= s.lit ? T.borderVisible
                 : (s.live && index === s.lit - 1) ? T.accent
                 : s.tone === "good" ? T.success
                 : s.tone === "warn" ? T.warning
                 : s.tone === "bad" ? T.accent
                 : T.textDisplay
        }
    }
}
