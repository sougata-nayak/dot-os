import QtQuick
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.private.brightnesscontrolplugin

Meter {
    id: m
    ScreenBrightnessControl { id: control; isSilent: false }

    // The first display's values, read the way Plasma's brightness applet does.
    property string displayName: ""
    property int value: 0
    property int maximum: 0
    function update() {
        var model = control.displays;
        if (!model || model.rowCount() < 1) { maximum = 0; return; }
        var idx = model.index(0, 0);
        var role = name => model.KItemModels.KRoleNames.role(name);
        displayName = model.data(idx, role("displayName"));
        value = model.data(idx, role("brightness"));
        maximum = model.data(idx, role("maxBrightness"));
    }
    Connections {
        target: control.displays
        function onDataChanged() { m.update(); }
        function onModelReset() { m.update(); }
        function onRowsInserted() { m.update(); }
        function onRowsRemoved() { m.update(); }
    }
    Component.onCompleted: update()

    readonly property bool available: control.isBrightnessAvailable && maximum > 0
    label: "Brightness"
    fraction: maximum > 0 ? value / maximum : 0
    reading: Math.round(fraction * 100) + "%"
    interactive: available
    onPicked: f => control.setBrightness(displayName, Math.max(1, Math.round(f * maximum)))
}
