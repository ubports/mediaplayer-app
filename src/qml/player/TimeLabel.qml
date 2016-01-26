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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "../sdk"

Label {
    id: _TimeLabel
    objectName: "TimeLine.TimeLabel"

    property string currentTime
    property string remainingTime

    color: "#e8e1d0"
    fontSize: "small"
    state: "PROGRESSIVE"
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignRight

    states: [
        State {
            name: "PROGRESSIVE"
            PropertyChanges { target: _TimeLabel; text: _TimeLabel.currentTime }
        },
        State {
            name: "DEGRESSIVE"
            PropertyChanges { target: _TimeLabel; text: "- %1".arg(_TimeLabel.remainingTime) }
        }
    ]

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (_TimeLabel.state === "PROGRESSIVE") {
                _TimeLabel.state = "DEGRESSIVE"
            } else {
                _TimeLabel.state = "PROGRESSIVE"
            }
        }
    }
}
