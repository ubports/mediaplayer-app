/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Renato Araujo Oliveira Filho <renato@canonical.com>
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
import Ubuntu.Components 1.1


InverseMouseArea {
    id: root

    property bool active: false
    default property alias controls: contents.children
    readonly property bool fullVisible: (spacer.height === 0)

    function dismiss()
    {
        dismissControls.restart()
    }

    function abortDismiss()
    {
        dismissControls.stop()
    }

    sensingArea: parent

    hoverEnabled: true
    onExited: {
        abortDismiss()
        active = true
    }

    onEntered: {
        dismiss()
    }

    Timer {
        id: dismissControls

        running: false
        interval: 5000
        repeat: false
        onTriggered: root.active = false
    }

    Column {
        anchors.fill: parent
        Item {
            id: spacer
            anchors {
                left: parent.left
                right: parent.right
            }
            height: root.active ? 0 : contents.height
        }
        Item {
            id: contents
            anchors {
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height
        }
    }

    states: [
        State {
            name: "active"
            when: root.active
            PropertyChanges {
                target: spacer
                height: 0
                enabled: false
            }
        },
        State {
            name: "deActive"
            when: !root.active
            PropertyChanges {
                target: spacer
                height: contents.height
                enabled: true
            }
        }
    ]

    transitions: [
        Transition {
            from: "deActive"
            to: "active"
            UbuntuNumberAnimation {
                target: spacer
                property: "height"
                duration: UbuntuAnimation.FastDuration
            }
        },
        Transition {
            from: "active"
            to: "deActive"
            UbuntuNumberAnimation {
                target: spacer
                property: "height"
                duration: UbuntuAnimation.SlowDuration
            }
        }
    ]
}
