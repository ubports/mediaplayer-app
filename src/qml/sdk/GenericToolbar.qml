/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import "mathUtils.js" as MathUtils

/*!
    \internal
    \qmltype GenericToolbar
    \inqmlmodule Ubuntu.Components 0.1
    \ingroup ubuntu
*/
Item {
    id: bottomBar

    default property alias contents: bar.data

    /*!
      When active, the bar is visible, otherwise it is hidden.
      Use bottom edge swipe up/down to activate/deactivate the bar.
      The active property is not updated until the swipe gesture is completed.
     */
    property bool active: false

    /*!
      Disable bottom edge swipe to activate/deactivate the toolbar.
     */
    property bool lock: false

    /*!
      How much of the toolbar to show when starting interaction.
     */
    property real hintSize: units.gu(1)

    /*!
     Notify when the toolbar is fully visible
    */
    readonly property bool ready: bar.y == 0

    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    onActiveChanged: {
        if (active) state = "spread";
        else state = "";
    }

    onLockChanged: {
        if (state == "hint" || state == "moving") {
            draggingArea.finishMoving();
        }
    }

    states: [
        State {
            name: "hint"
            PropertyChanges {
                target: bar
                y: bar.height - bottomBar.hintSize
            }
        },
        State {
            name: "moving"
            PropertyChanges {
                target: bar
                y: MathUtils.clamp(bar.height, draggingArea.mouseY - internal.movingDelta, 0, bar.height)
            }
        },
        State {
            name: "spread"
            PropertyChanges {
                target: bar
                y: 0
            }
        },
        State {
            name: ""
            PropertyChanges {
                target: bar
                y: bar.height
            }
        }
    ]

    transitions: [
        Transition {
            to: ""
            PropertyAnimation {
                target: bar
                properties: "y"
                duration: 175
                easing.type: Easing.OutQuad
            }
        },
        Transition {
            to: "hint"
            PropertyAnimation {
                target: bar
                properties: "y"
                duration: 175
                easing.type: Easing.OutQuad
            }
        },
        Transition {
            to: "spread"
            PropertyAnimation {
                target: bar
                properties: "y"
                duration: 175
                easing.type: Easing.OutQuad
            }
        }
    ]

    QtObject {
        id: internal
        property string previousState: ""
        property int movingDelta
    }

    onStateChanged: {
        if (state == "hint") {
            internal.movingDelta = bottomBar.hintSize + draggingArea.initialY - bar.height;
        } else if (state == "moving" && internal.previousState == "spread") {
            internal.movingDelta = draggingArea.initialY;
        } else if (state == "spread") {
            bottomBar.active = true;
        } else if (state == "") {
            bottomBar.active = false;
        }
        internal.previousState = state;
    }

    DraggingArea {
        orientation: Qt.Vertical
        id: draggingArea
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: bottomBar.active ? bar.height + units.gu(1) : units.gu(3)
        zeroVelocityCounts: true
        propagateComposedEvents: true
        visible: !bottomBar.lock

        property int initialY
        onPressed: {
            initialY = mouseY;
            if (bottomBar.state == "") bottomBar.state = "hint";
            else bottomBar.state = "moving";
            mouse.accepted = false
        }

        onPositionChanged: {
            if (bottomBar.state == "hint" && mouseY < initialY) {
                bottomBar.state = "moving";
            }
            mouse.accepted = false
        }

        onReleased: {
            finishMoving()
            mouse.accepted = false
        }
        // Mouse cursor moving out of the window while pressed on desktop
        // TODO: Comment it for now since this is causing toolbar to flick on device due the several mouse areas overlaping
        // onCanceled: finishMoving()

        // FIXME: Make all parameters below themable.
        //  The value of 44 was copied from the Launcher.
        function finishMoving() {
            if (draggingArea.dragVelocity < -44) {
                bottomBar.state = "spread";
            } else if (draggingArea.dragVelocity > 44) {
                bottomBar.state = "";
            } else {
                bottomBar.state = (bar.y < bar.height / 2) ? "spread" : "";
            }
        }
    }

    Item {
        id: bar

        objectName: "GenericToolbar.Bar"
        height: parent.height
        anchors {
            left: parent.left
            right: parent.right
        }

        visible: y != height
        y: bottomBar.active ? 0 : height
    }
}
