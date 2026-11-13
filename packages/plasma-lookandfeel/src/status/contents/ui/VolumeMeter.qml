import QtQuick
import org.kde.plasma.private.volume

Meter {
    readonly property var sink: PreferredDevice.sink
    readonly property int percent: sink ? Math.round(sink.volume / PulseAudio.NormalVolume * 100) : 0
    label: "Volume"
    reading: !sink ? "—" : sink.muted ? "Muted" : percent + "%"
    fraction: sink && !sink.muted ? Math.min(1, sink.volume / PulseAudio.NormalVolume) : 0
    interactive: !!sink
    onPicked: f => { if (sink) { sink.muted = false; sink.volume = Math.round(f * PulseAudio.NormalVolume); } }
}
