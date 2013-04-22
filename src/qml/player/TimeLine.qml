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
import Ubuntu.Components 0.1
import "../sdk"

Item {
    id: _timeLine

    property alias minimumValue: _slider.minimumValue
    property alias maximumValue: _slider.maximumValue
    property alias pressed: _slider.pressed
    property alias liveValue: _slider.value
    property real value: 0
    property string currentTime
    property string remainingTime

    signal clicked(bool insideThumb)

    objectName: "TimeLine"
    // Make sure that the Slider value will be in sync with the video progress after the user click over the slider
    // The Slider components break the binding when the user interact with the component because of that a simple
    // "property alias value: _slider.value" does not work
    Binding { target: _slider; property: "value"; value: _timeLine.value }

    Component.onCompleted: {
        var result = Theme.loadTheme(Qt.resolvedUrl("../theme/theme.qmltheme"))
    }

    Slider {
        id: _slider

        objectName: "TimeLine.Slider"
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: _TimeLabel.left
            rightMargin: units.gu(2)
        }

        minimumValue: 0
        maximumValue: 1000
        live: true
        onValueChanged: {
            if (value > 0) {
                _timeLine.currentTime = formatProgress(value)
                if (_slider.maximumValue > 0) {
                    _timeLine.remainingTime = formatProgress(_slider.maximumValue - value)
                } else {
                    _timeLine.remainingTime = "unknow"
                }
            } else {
                _timeLine.currentTime = "0:00:00"
            }
        }

        onTouched: {
            _timeLine.clicked(onThumb)
        }
    }

    Label {
        id: _TimeLabel

        objectName: "TimeLine.TimeLabel"
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
                PropertyChanges { target: _TimeLabel; text: _timeLine.currentTime }
            },
            State {
                name: "DEGRESSIVE"
                PropertyChanges { target: _TimeLabel; text: "- " + _timeLine.remainingTime }
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

    function formatProgress(time) {
        var hour = 0
        var min = 0
        var secs = 0
        time = Math.floor(time)

        secs = time % 60
        time = Math.floor(time / 60)
        min = time % 60
        hour = Math.floor(time / 60)

        if (secs < 10) secs = "0" + secs
        if (min < 10) min = "0" + min
        if (hour < 10) hour = "0" + hour

        return hour + ":" + min + ":" + secs
    }
}
