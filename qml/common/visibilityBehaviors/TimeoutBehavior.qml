/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


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
