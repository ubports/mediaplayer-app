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
import Ubuntu.Components 1.1

Item {
    id: main
    anchors.fill: parent

    // properties to be published:
    property Item bar: backgroundShape
    property Item thumb: thumbShape

    // private properties
    property real thumbSpacing: units.gu(1)
    property real liveValue: SliderUtils.liveValue(item)
    property real normalizedValue: SliderUtils.normalizedValue(item)

    property real thumbSpace: backgroundShape.width - (2.0 * thumbSpacing + thumbWidth)
    property real thumbWidth: item.height - thumbSpacing

    BorderImage {
        id: backgroundFilledShape

        border {
            left: 7
            top: 7
            right: 7
            bottom: 7
        }
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        source: "artwork/slider_shape.png"
        anchors {
            verticalCenter:  parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(0.2)
        }
        height: units.gu(1)
        width: normalizedValue * thumbSpace + thumbSpacing + (thumbShape.width  / 2)
    }

    BorderImage {
        id: backgroundShape

        border {
            left: 7
            top: 7
            right: 7
            bottom: 7
        }
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        source: "artwork/slider_bg.png"
        anchors {
            verticalCenter:  parent.verticalCenter
            left: parent.left
            right: parent.right
        }
        height: units.gu(1.5)
    }

    Image {
        id: thumbShape

        x: backgroundShape.x + thumbSpacing + normalizedValue * thumbSpace
        anchors.verticalCenter: backgroundShape.verticalCenter
        width: thumbWidth
        height: thumbWidth
        source: "artwork/slider_handle.png"
    }
}
