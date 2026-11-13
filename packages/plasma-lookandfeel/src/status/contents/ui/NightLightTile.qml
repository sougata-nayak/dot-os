import QtQuick
import org.kde.plasma.plasma5support as P5Support

Tile {
    id: tile
    signal runCommand(string cmd)
    property bool active: false
    label: "Night light"
    on: active
    value: active ? "On" : "Off"

    // Read the current setting once.
    P5Support.DataSource {
        engine: "executable"
        connectedSources: ["kreadconfig6 --file kwinrc --group NightColor --key Active --default false"]
        onNewData: (source, data) => {
            tile.active = String(data["stdout"]).trim() === "true";
            disconnectSource(source);
        }
    }
    onToggled: {
        active = !active;
        runCommand("kwriteconfig6 --file kwinrc --group NightColor --key Active " + active
                   + " && qdbus6 org.kde.KWin /KWin reconfigure");
    }
}
