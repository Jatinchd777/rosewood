import QtQuick
import Quickshell
import Quickshell.Services.Pam

// Shared state between all lock surfaces (one per screen).
Scope {
    id: root

    signal unlocked()
    signal failed()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false

    function tryUnlock() {
        if (root.currentText === "") return
        root.unlockInProgress = true
        pam.start()
    }

    PamContext {
        id: pam

        // "pam" is resolved relative to this file (Quickshell requires pam contexts)
        // to use a custom, include-free configuration.
        configDirectory: "pam"
        config: "password.conf"

        // pam_unix asks for a response for the password prompt
        onPamMessage: {
            if (pam.responseRequired) {
                pam.respond(root.currentText)
            }
        }

        // pam_unix sends no important messages, so the completion state is all we need
        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocked()
            } else {
                root.currentText = ""
                root.showFailure = true
            }

            root.unlockInProgress = false
        }
    }
}

