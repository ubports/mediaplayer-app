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
import "../common/utils.js" as Utils
import "../common/units.js" as Units

VolumeIndicator {
    property bool extensionShown: volumeBarClip.height != 0
    property alias extensionWidth: volumeBarClip.width

    ownBackground: false

    Rectangle {
        id: volumeBarClip
        y: indicatorsBackground.y + indicatorsBackground.height - parent.y
        x: (parent.width - width) / 2
        width: volumeBarBackgroundBorder.width + volumeBarBackgroundBorder.border.width
        height: active ? volumeBarBackgroundBorder.height : 0
        Behavior on height { NumberAnimation { } }
        color: "transparent"
        clip: true

        Rectangle {
            id: volumeBarBackground
            anchors.horizontalCenter: volumeBarBackgroundBorder.horizontalCenter
            anchors.bottom: volumeBarClip.bottom
            anchors.bottomMargin: volumeBarBackground.radius

            color: Utils.darkAubergine
            opacity: 0.5
            height: Units.tvPx(280)
            width: Units.tvPx(100)
            radius: Units.tvPx(10)
        }

        MouseArea {
            anchors.fill: volumeBarBackground
            enabled: active
        }

        Rectangle {
            id: volumeBarBackgroundBorder
            x: border.width / 2
            anchors.bottom: volumeBarClip.bottom
            anchors.bottomMargin: volumeBarBackground.radius

            color: "transparent"
            height: volumeBarBackground.height + border.width / 2
            width: volumeBarBackground.width + border.width
            radius: volumeBarBackground.radius + border.width
            opacity: 0.2
            border.color: "white"
            border.width: Units.tvPx(2)
        }

        BorderImage {
            id: volumeBarOutline

            anchors.top: volumeBarBackground.top
            anchors.topMargin: 10
            anchors.horizontalCenter: volumeBarBackground.horizontalCenter

            source: "artwork/volume_bar.sci"

            height: volumeBarBackground.height - volumeBarBackground.radius
            width: Units.tvPx(54)
        }

        BorderImage {
            id: volumeBarFiller
            source: "artwork/volume_filler.sci"

            anchors.horizontalCenter: volumeBarOutline.horizontalCenter
            anchors.bottom: volumeBarOutline.bottom
            width: Units.tvPx(58)
            height: Units.tvPx(Math.round(58 + mediaPlayer.volume * 212))
        }

        MouseArea {
            id: mouseArea
            anchors.fill: volumeBarOutline
            anchors.margins: Units.tvPx(19)
            enabled: active
            onClicked: {
                if (mouseY == 0) video.volume = 1.0
                else video.volume = Math.min((height - mouseY) / height, 1.0)
            }
            drag.target: slider
            drag.axis: "YAxis"
            drag.minimumY: 0
            drag.maximumY: height

            Item {
                id: slider
                anchors.horizontalCenter: parent.horizontalCenter
                onYChanged: if (mouseArea.drag.active) video.volume = Math.min((mouseArea.height - y) / mouseArea.height, 1.0)
                Connections {
                    target: video
                    onVolumeChanged: slider.y = mouseArea.height - video.volume * mouseArea.height
                }
            }
        }
    }
}
