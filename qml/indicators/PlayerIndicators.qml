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
import "../common/units.js" as Units

FocusScope {
    width: row.width

    property alias leftIndicator: volume
    property variant focusedIndicator: volume

    Row {
        id: row
        spacing: Units.tvPx(11)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        PlayerVolumeIndicator {
            id: volume
            focus: true
            anchors.verticalCenter: parent.verticalCenter

            KeyNavigation.right: wifi

            onActiveFocusChanged: if (activeFocus) focusedIndicator = volume
        }

        Indicator {
            id: wifi
            source: "artwork/wifi.png"
            focusedSource: "artwork/wifi_orange.png"
            anchors.verticalCenter: parent.verticalCenter
            ownBackground: false

            KeyNavigation.left: volume
            KeyNavigation.right: system

            onActiveFocusChanged: if (activeFocus) focusedIndicator = wifi
        }

        Rectangle {
            id: time

            width: Units.tvPx(130)
            height: Units.tvPx(80)
            anchors.verticalCenter: parent.verticalCenter

            color: "transparent"

            CurrentTimeIndicator {
                anchors.centerIn: parent
            }
        }

        Indicator {
            id: system
            source: "artwork/cog.png"
            focusedSource: "artwork/cog_orange.png"
            anchors.verticalCenter: parent.verticalCenter
            ownBackground: false

            KeyNavigation.left: wifi

            onActiveFocusChanged: if (activeFocus) focusedIndicator = system
        }
    }
}
