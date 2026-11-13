import QtQuick
import org.kde.plasma.private.battery

Meter {
    BatteryControlModel { id: battery }
    readonly property bool present: battery.hasInternalBatteries === true
    readonly property int percent: Number(battery.percent) || 0
    label: "Battery"
    fraction: percent / 100
    reading: percent + "%" + (battery.pluggedIn ? " — charging" : percent <= 10 ? " — plug in" : "")
    alert: percent <= 10 && !battery.pluggedIn
}
