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
import QtMultimedia 5.0
import Ubuntu.Components 1.3
import "../sdk"

Slider {
    id: _slider
    objectName: "TimeLine.Slider"

    readonly property alias liveValue: _slider.value
    property real videoPosition: -1
    property variant playerStatus: MediaPlayer.NoMedia
    property string currentTime
    property string remainingTime
    property int finalSeekPosition: -1

    signal clicked(bool insideThumb)

    function formatProgress(time) {
        var hour = 0
        var min = 0
        var secs = 0
        time = Math.floor(time)

        secs = time % 60
        time = Math.floor(time / 60)
        min = time % 60
        hour = Math.floor(time / 60)

        if (secs < 10) secs = "0%1".arg(secs)
        if (min < 10) min = "0%1".arg(min)
        if (hour < 10) hour = "0%1".arg(hour)

        // TRANSLATORS: this refers to a duration/remaining time of the video, of which you can change the order.
        // %1 refers to hours, %2 refers to minutes and %3 refers to seconds.
        return  i18n.tr("%1:%2:%3").arg(hour).arg(min).arg(secs)
    }

    style: VideoSlider {property Item item: _slider}
    minimumValue: 0
    maximumValue: 1000
    live: true

    onFinalSeekPosition: _slider.value = _slider.finalSeekPosition / 1000

    onVideoPositionChanged: {
        if (_slider.playerStatus == MediaPlayer.EndOfMedia)
        {
            // On EndOfMedia status, make sure the slider returns to the beginning
            _slider.value = 0
        } else if (!_slider.pressed){
            // Else, pass all new positions through to the slider UI
            if (_slider.videoPosition >= (_slider.finalSeekPosition / 1000)) {
                _slider.value = _slider.videoPosition
            }
        }
    }

    onValueChanged: {
        if (value > 0) {
            _slider.currentTime = formatProgress(value)
            if (_slider.maximumValue > 0) {
                _slider.remainingTime = formatProgress(_slider.maximumValue - value)
            } else {
                // TRANSLATORS: this refers to an unknown duration.
                _slider.remainingTime = i18n.tr("unknown")
            }
        } else {
            _slider.currentTime = i18n.tr("0:00:00")
        }
    }

    onTouched: {
        _slider.clicked(onThumb)
    }
}
