import QtQuick
import org.kde.bluezqt as BluezQt

Tile {
    readonly property var manager: BluezQt.Manager
    readonly property bool present: manager.adapters.length > 0
    label: "Bluetooth"
    on: present && manager.bluetoothOperational
    value: !present ? "Unavailable" : manager.bluetoothOperational ? "On" : "Off"
    enabled: present
    onToggled: manager.bluetoothBlocked = !manager.bluetoothBlocked
}
