import QtQuick
import org.kde.plasma.private.battery

Reading {
    BatteryControlModel { id: battery }
    readonly property bool present: battery.hasInternalBatteries === true
    readonly property int percent: Number(battery.percent) || 0
    label: "Bat"
    value: percent + "%"
    alert: present && percent <= 10 && !battery.pluggedIn
}
