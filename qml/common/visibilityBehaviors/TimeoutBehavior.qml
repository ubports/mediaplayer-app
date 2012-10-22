import QtQuick 2.0

/*
    This behavior will show the target onFocusIn and hide it
    onFocusOut or after a timeout, regardless of focus.

    If you forward key events to this behavior, the timer will
    get reset on every Keys.onPress.

    Binding forcedVisible to VisibilityController's forceVisible
    will prevent the behavior to hide as soon as visibility is
    unforced
*/

BaseBehavior {
    id: timeout

    property bool forcedVisible: false
    property alias interval: hideTimer.interval

    function restartTimer() {
        if (hideTimer.running) hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: shown = false
    }

    Connections {
        target: timeout.target
        onActiveFocusChanged: {
            if (timeout.target.activeFocus) {
                shown = true
                hideTimer.restart()
            } else {
                shown = false
                hideTimer.stop()
            }
        }
    }

    onForcedVisibleChanged: {
        if (forcedVisible) {
            hideTimer.stop()
            shown = true
        } else {
            hideTimer.restart()
        }
    }

    Keys.onPressed: restartTimer()
}
