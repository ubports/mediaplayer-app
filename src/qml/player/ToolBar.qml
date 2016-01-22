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

MouseArea {
    id: root

    property bool anchored: false
    property bool active: false
    default property alias controls: contents.children
    readonly property bool fullVisible: (spacer.height === 0)

    property bool _visible: anchored || active || containsMouse
    property bool _skipAnimation: false

    function hide()
    {
        _skipAnimation = true
        active = false
    }

    hoverEnabled: true

    Column {
        anchors.fill: parent
        Item {
            id: spacer
            anchors {
                left: parent.left
                right: parent.right
            }
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
            when: root._visible
            PropertyChanges {
                target: spacer
                height: 0
                enabled: false
            }
        },
        State {
            name: "deActive"
            when: !root._visible
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
            SequentialAnimation {
                PauseAnimation {
                    duration: root._skipAnimation ? 0 : 3000
                }
                UbuntuNumberAnimation {
                    target: spacer
                    property: "height"
                    duration: UbuntuAnimation.SlowDuration
                }
                PropertyAction {
                    target: root
                    property: "_skipAnimation"
                    value: false
                }
            }
        }
    ]
}
