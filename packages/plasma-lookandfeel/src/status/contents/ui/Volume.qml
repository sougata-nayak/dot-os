import QtQuick
import org.kde.plasma.private.volume

Item {
    id: vol
    readonly property var sink: PreferredDevice.sink
    implicitWidth: reading.implicitWidth
    implicitHeight: reading.implicitHeight
    Reading {
        id: reading
        label: "Vol"
        value: !vol.sink ? "—" : vol.sink.muted ? "Mute" : Math.round(vol.sink.volume / PulseAudio.NormalVolume * 100)
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        onClicked: if (vol.sink) vol.sink.muted = !vol.sink.muted
        onWheel: wheel => {
            if (!vol.sink) return;
            var step = PulseAudio.NormalVolume / 20;
            var v = vol.sink.volume + (wheel.angleDelta.y > 0 ? step : -step);
            vol.sink.volume = Math.max(PulseAudio.MinimalVolume, Math.min(PulseAudio.NormalVolume, v));
            if (vol.sink.muted) vol.sink.muted = false;
        }
    }
}
