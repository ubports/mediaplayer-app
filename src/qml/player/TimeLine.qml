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

    anchors.margins: units.gu(2)

    Label {
        id: _currentTimeLabel

        anchors.verticalCenter: _slider.verticalCenter
        anchors.left: parent.left
        anchors.margins: units.gu(2)
        width: units.gu(6)

        color: "#e8e1d0"
        font.weight: Font.DemiBold
        fontSize: "medium"
    }

    Slider {
        id: _slider

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: _currentTimeLabel.right
        anchors.right: _remainingTimeLabel.left
        anchors.leftMargin: units.gu(3)
        anchors.rightMargin: units.gu(3)

        minimumValue: 0
        maximumValue: 1000
        value: 100

        function formatValue(v) {
            if (_slider.value > 0) {
                _currentTimeLabel.text = formatProgress(_slider.value)
                if (_slider.maximumValue > 0) {
                    _remainingTimeLabel.text = formatProgress((_slider.maximumValue - _slider.value))
                } else {
                    _remainingTimeLabel.text = "unknow"
                }
            } else {
                _currentTimeLabel.text = "0:00:00"
            }
            return ""
        }
    }

    Label {
        id: _remainingTimeLabel

        anchors.verticalCenter: _slider.verticalCenter
        anchors.right: parent.right
        anchors.margins: units.gu(2)
        width: units.gu(6)

        color: "#e8e1d0"
        font.weight: Font.DemiBold
        fontSize: "medium"
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
