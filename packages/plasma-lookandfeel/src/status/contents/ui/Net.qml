import QtQuick
import org.kde.plasma.networkmanagement as PlasmaNM

Reading {
    PlasmaNM.NetworkStatus { id: status }
    label: "Net"
    readonly property string active: status.activeConnections.toLowerCase()
    value: active === "" ? "Off"
         : /wi-?fi|wireless|wlan/.test(active) && active.indexOf("wired") === -1 ? "Wi-Fi" : "On"
    alert: status.activeConnections === ""
}
