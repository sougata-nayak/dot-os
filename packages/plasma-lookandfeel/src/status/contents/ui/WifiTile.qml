import QtQuick
import org.kde.plasma.networkmanagement as PlasmaNM

Tile {
    PlasmaNM.NetworkStatus { id: status }
    PlasmaNM.EnabledConnections { id: enabled }
    PlasmaNM.Handler { id: handler }
    readonly property string active: status.activeConnections
    label: "Wi-Fi"
    on: enabled.wirelessEnabled
    value: !enabled.wirelessHwEnabled ? "Unavailable"
         : !enabled.wirelessEnabled ? "Off"
         : (/wi-?fi|wireless|wlan/i.test(active) ? active.split(":")[0] : "On")
    enabled: enabled.wirelessHwEnabled
    onToggled: handler.enableWireless(!enabled.wirelessEnabled)
}
