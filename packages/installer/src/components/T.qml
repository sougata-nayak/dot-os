// Design tokens for the installer. build.py fills the token markers from
// design-system/tokens.json (dark theme), so these never drift.
pragma Singleton
import QtQuick

QtObject {
    readonly property color black: "@black@"
    readonly property color surface: "@surface@"
    readonly property color surfaceRaised: "@surface-raised@"
    readonly property color border: "@border@"
    readonly property color borderVisible: "@border-visible@"
    readonly property color textDisabled: "@text-disabled@"
    readonly property color textSecondary: "@text-secondary@"
    readonly property color textPrimary: "@text-primary@"
    readonly property color textDisplay: "@text-display@"
    readonly property color accent: "@accent@"
    readonly property color success: "@success@"
    readonly property color warning: "@warning@"

    readonly property string mono: "Space Mono"
    readonly property string sans: "Space Grotesk"
    readonly property string display: "Doto"

    readonly property int controlMin: @control-min@
    readonly property int radiusTechnical: @radius-technical@
    readonly property int radiusCompact: @radius-compact@

    // Page layout from design-system/boards/Install*.dc.html.
    readonly property int padX: 48
    readonly property int padY: 32
    readonly property int colLeft: 440
    readonly property int colGap: 64

    readonly property string version: "@version@"

    // Step names as the boards print them; Calamares' own names otherwise.
    function stepName(name) {
        var map = { "Partitions": "Disk", "Users": "User" };
        return map[name] !== undefined ? map[name] : name;
    }
    // Button labels arrive with mnemonics ("&Next").
    function plain(label) { return label.replace(/&(?!&)/g, ""); }
}
