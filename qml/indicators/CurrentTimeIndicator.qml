/*
 * This file is part of unity-2d
 *
 * Copyright 2011 Canonical Ltd.
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
import "../common"

TextCustom {
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: parent.setTime()
    }

    fontSize: "large"

    color: "white"
    smooth: true

    Component.onCompleted: setTime()

    function setTime()
    {
        text = Qt.formatTime(new Date(), "hh:mm")
    }
}
