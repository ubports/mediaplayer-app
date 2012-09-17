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

import QtQuick 1.0
import "../common"
import "../common/utils.js" as Utils
import "../common/units.js" as Units

FocusScope {
    property alias background: backgroundRectangle
    property bool ownBackground: true
    property bool active: false
    property bool activable: false
    property alias source: icon.source
    property alias focusedSource: focusedIcon.source

    width: icon.width
    height: icon.height

    Rectangle {
        id: backgroundRectangle
        width: parent.width
        height: parent.height
        color: Utils.darkAubergine
        opacity: parent.activeFocus && ownBackground ? 0.2 : 0
        radius: Units.tvPx(10)

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity { NumberAnimation {} }
        Behavior on width { NumberAnimation {} }
        Behavior on height { NumberAnimation {} }
    }

    Rectangle {
        id: backgroundRectangleBorder
        width: background.width + border.width
        height: background.height + border.width
        color: "transparent"
        opacity: parent.activeFocus && ownBackground ? 0.2 : 0
        radius: background.radius + border.width

        anchors.centerIn: backgroundRectangle

        border.color: "white"
        border.width: Units.tvPx(3)

        Behavior on opacity { NumberAnimation {} }
    }

    BorderImage {
        id: glow
        source: "artwork/indicator_glow.sci"
        anchors.top: parent.top
        anchors.topMargin: -20
        anchors.horizontalCenter: parent.horizontalCenter
        width: backgroundRectangle.width + 40
        height: backgroundRectangle.height + 40
        smooth: true
        opacity: icon.activeFocus && !active ? 1 : 0
        Behavior on opacity { NumberAnimation {} }
    }

    Image {
        id: focusedIcon
        opacity: 1 - icon.opacity

        smooth: true
    }

    Image {
        id: icon
        focus: true
        opacity: activeFocus ? 0 : 1
        Behavior on opacity { NumberAnimation { } }

        width: Units.tvPx(sourceSize.width)
        height: Units.tvPx(sourceSize.height)
        smooth: true

        Keys.onPressed: {
            if (!event.isAutoRepeat)
            {
                if (event.key == Qt.Key_Return ||
                    event.key == Qt.Key_Enter ||
                    (event.key == Qt.Key_Escape && active))
                {
                    event.accepted = true
                    if (activable) {
                        active = !active
                    }
                }
            }
        }
    }
}
