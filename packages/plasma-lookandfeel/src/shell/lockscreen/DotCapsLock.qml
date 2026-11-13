// Loaded on its own so a missing module can never stop the lock screen loading.
import QtQuick
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator

Item {
    readonly property bool on: capsState.locked
    KeyboardIndicator.KeyState {
        id: capsState
        key: Qt.Key_CapsLock
    }
}
