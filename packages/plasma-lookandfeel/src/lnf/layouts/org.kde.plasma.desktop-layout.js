// DOT OS default desktop: a 32px top bar, a floating dock, the dot grid.
// Design: design-system/boards/Main.dc.html. Runs once, for a new user.

function attempt(fn) {
    try { fn(); } catch (e) { print("dot-os layout: " + e); }
}

// ---- Top bar: workspaces left, clock centred, status right ----
var bar = new Panel;
bar.location = "top";
bar.height = 32;
attempt(function () { bar.hiding = "none"; });
attempt(function () { bar.lengthMode = "fill"; });
attempt(function () { bar.floating = false; });

if (knownWidgetTypes.indexOf("org.dotos.workspaces") !== -1) {
    bar.addWidget("org.dotos.workspaces");
} else {
    bar.addWidget("org.kde.plasma.pager");
}
bar.addWidget("org.kde.plasma.panelspacer");
// The DOT OS clock; the stock digital clock if it is not installed.
if (knownWidgetTypes.indexOf("org.dotos.clock") !== -1) {
    bar.addWidget("org.dotos.clock");
} else {
    bar.addWidget("org.kde.plasma.digitalclock");
}
bar.addWidget("org.kde.plasma.panelspacer");
if (knownWidgetTypes.indexOf("org.dotos.status") !== -1) {
    bar.addWidget("org.dotos.status");
}
var tray = bar.addWidget("org.kde.plasma.systemtray");
// The status readout replaces the tray's network, volume and battery icons;
// they stay one click away under the tray's arrow.
attempt(function () {
    var trayId = tray.readConfig("SystrayContainmentId");
    var trayContainment = desktopById(trayId);
    trayContainment.currentConfigGroup = ["General"];
    trayContainment.writeConfig("hiddenItems", [
        "org.kde.plasma.networkmanagement", "org.kde.plasma.volume", "org.kde.plasma.battery",
        "org.kde.plasma.brightness", "org.kde.plasma.bluetooth", "org.kde.plasma.notifications",
        "org.kde.plasma.devicenotifier", "org.kde.plasma.clipboard", "org.kde.plasma.keyboardlayout",
        "org.kde.plasma.manage-inputmethod", "org.kde.plasma.mediacontroller", "org.kde.kdeconnect",
        "org.kde.kscreen", "org.kde.plasma.cameraindicator", "org.kde.plasma.printmanager",
        "org.kde.plasma.vault", "org.kde.plasma.weather", "org.kde.plasma.keyboardindicator"
    ]);
});

// ---- Dock: launcher and tasks in a floating pill ----
var dock = new Panel;
dock.location = "bottom";
dock.height = 60;
attempt(function () { dock.alignment = "center"; });
attempt(function () { dock.lengthMode = "fit"; });
attempt(function () { dock.floating = true; });
attempt(function () { dock.hiding = "dodgewindows"; });

var launcher = dock.addWidget("org.kde.plasma.kickoff");
var tasks = dock.addWidget("org.kde.plasma.icontasks");
attempt(function () {
    tasks.currentConfigGroup = ["General"];
    tasks.writeConfig("launchers", [
        "applications:org.kde.konsole.desktop",
        "preferred://filemanager",
        "preferred://browser",
        "applications:org.kde.discover.desktop",
        "applications:systemsettings.desktop"
    ]);
    tasks.writeConfig("indicateAudioStreams", false);
    tasks.writeConfig("fill", false);
});

// ---- Wallpaper ----
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    var desk = desktopsArray[j];
    desk.wallpaperPlugin = "org.dotos.dotgrid";
    // Desktop icons (like the live ISO's installer) line up on the right edge,
    // clear of the clock and cards on the left.
    attempt(function () {
        desk.currentConfigGroup = ["General"];
        desk.writeConfig("alignment", 1);
    });
    // Desktop widgets, placed as on the Main board.
    // The desktop reads widget positions from these keys (in the containment's
    // own group, relative to the area below the top bar); without them the
    // widgets would jump to the corner at the next login.
    attempt(function () {
        var clockWidget = desk.addWidget("org.dotos.desktopclock", 48, 80, 368, 144);
        var systemWidget = desk.addWidget("org.dotos.system", 48, 224, 288, 464);
        var saved = "Applet-" + clockWidget.id + ":48,48,368,144,0;" +
                    "Applet-" + systemWidget.id + ":48,192,288,464,0;";
        desk.currentConfigGroup = [];
        desk.writeConfig("ItemGeometriesHorizontal", saved);
        // Also the logical size of the DOT OS default display (3840x2160 at
        // 250%), which the first login switches to after this script runs.
        var g = screenGeometry(desk.screen);
        var sizes = [Math.round(g.width) + "x" + Math.round(g.height), "1536x864"];
        for (var s = 0; s < sizes.length; s++) {
            desk.writeConfig("ItemGeometries-" + sizes[s], saved);
        }
    });
}
