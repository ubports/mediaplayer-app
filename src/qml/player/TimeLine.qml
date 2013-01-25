/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    property alias minimumValue: _slider.minimumValue
    property alias maximumValue: _slider.maximumValue
    property alias value: _slider.value
    property string currentTime
    property string remainingTime

    Slider {
        id: _slider

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: _TimeLabel.left
            rightMargin: units.gu(2)
        }

        minimumValue: 0
        maximumValue: 1000
        value: 100

        function formatValue(v) {
            if (_slider.value > 0) {
                currentTime = formatProgress(_slider.value)
                if (_slider.maximumValue > 0) {
                    remainingTime = formatProgress((_slider.maximumValue - _slider.value))
                } else {
                    remainingTime = "unknow"
                }
            } else {
                currentTime = "0:00:00"
            }
            return ""
        }
    }

    Label {
        id: _TimeLabel

        anchors {
            verticalCenter: _slider.verticalCenter
            right: parent.right
            margins: units.gu(2)
        }

        width: units.gu(6)

        color: "#e8e1d0"
        font.weight: Font.DemiBold
        fontSize: "medium"
        state: "PROGRESSIVE"

        states: [
            State {
                name: "PROGRESSIVE"
                PropertyChanges { target: _TimeLabel; text: currentTime }
            },
            State {
                name: "DEGRESSIVE"
                PropertyChanges { target: _TimeLabel; text: remainingTime }
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


    function formatProgress(value) {
        var hour = 0
        var min = 0
        var secs = 0
        value = Math.floor(value)

        console.debug("Format progress: " + value)

        while (value > 3600) {
            hour += 1
            value -= 3600
        }

        while (value > 60) {
            min += 1
            value -= 60
        }

        secs = value;

        if (min < 10) {
            min = "0" + min
        }

        if (secs < 10) {
            secs = "0" + secs
        }



        return hour + ":" + min + ":" + secs
    }

}
