import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

PwObjectTracker {
    id: root

    property var stateEngine
    property var windowRef

    signal volumeChanged()

    objects: Pipewire.defaultAudioSink
        ? [Pipewire.defaultAudioSink]
        : []

    property var activeAudio:
        Pipewire.defaultAudioSink
            ? Pipewire.defaultAudioSink.audio
            : null

    property real currentVolume:
        activeAudio ? activeAudio.volume : 0.0

    onCurrentVolumeChanged: volumeChanged()

    onVolumeChanged: {
        if (windowRef && windowRef.isFullyLoaded && stateEngine) {
            stateEngine.showVolume()
        }
    }
}
