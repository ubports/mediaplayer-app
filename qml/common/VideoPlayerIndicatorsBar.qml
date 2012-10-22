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
import "../common/utils.js" as Utils
import "../common/units.js" as Units
import "../indicators"

FocusScope {
    property bool indicatorActivated: barBleedLocation != 0
    property int barBleedLocation: focusedIndicator.extensionShown && focusedIndicator.extensionShown != 0 ? indicators.x + focusedIndicator.x + (focusedIndicator.width - focusedIndicator.extensionWidth) / 2 : 0
    property int barBleedWidth: focusedIndicator.extensionShown && focusedIndicator.extensionShown != 0 ? focusedIndicator.extensionWidth : 0
    property alias focusedIndicator: indicators.focusedIndicator

    Behavior on y { NumberAnimation { duration: 125 } }

    Rectangle {
        id: indicatorsBackground
        height: parent.height - backgroundBorderLeft.height
        width: parent.width

        color: Utils.darkAubergineDesaturated
        opacity: 0.5

        Rectangle {
            id: backgroundBorderLeft
            width: barBleedLocation
            height: 2
            anchors.top: parent.bottom
            color: "white"
            opacity: 0.4
        }

        Rectangle {
            id: backgroundBorderRight
            x: barBleedLocation + barBleedWidth
            width: parent.width - barBleedLocation - barBleedWidth
            height: backgroundBorderLeft.height
            anchors.top: parent.bottom
            color: backgroundBorderLeft.color
            opacity: backgroundBorderLeft.opacity
        }
    }

    PlayerIndicators {
        id: indicators
        anchors.top: indicatorsBackground.top
        anchors.bottom: indicatorsBackground.bottom
        anchors.right: parent.right
        anchors.rightMargin: Units.tvPx(27)
        focus: true

        Keys.onPressed: {
            // eat the events the indicators bar usually processes
            if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) {
                event.accepted = true
            }
        }

        Keys.onReleased: {
            // eat the events the indicators bar usually processes
            if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) {
                event.accepted = true
            }
        }

        onActiveFocusChanged: {
            if (!activeFocus) {
                focusedIndicator.active = false
            }
        }
    }
}
