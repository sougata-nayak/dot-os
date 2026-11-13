import QtQuick
import org.kde.notificationmanager as NotificationManager

Tile {
    NotificationManager.Settings { id: settings }
    readonly property bool inhibited: settings.notificationsInhibitedUntil > new Date()
    label: "Do not disturb"
    on: inhibited
    value: inhibited ? "Until " + Qt.formatTime(settings.notificationsInhibitedUntil, "HH:mm") : "Off"
    onToggled: {
        if (inhibited) {
            settings.notificationsInhibitedUntil = new Date(0);
        } else {
            var d = new Date();
            d.setHours(d.getHours() + 1);
            settings.notificationsInhibitedUntil = d;
        }
        settings.save();
    }
}
