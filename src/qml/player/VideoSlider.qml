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
import Ubuntu.Components 1.3

Item {
    id: main
    anchors.fill: parent

    // properties to be published:
    property Item bar: backgroundShape
    property Item thumb: thumbShape

    // private properties
    readonly property real thumbSpacing: units.gu(1)
    readonly property real liveValue: SliderUtils.liveValue(item)
    readonly property real normalizedValue: SliderUtils.normalizedValue(item)
    readonly property real thumbWidth: item.height - thumbSpacing

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
        width: (normalizedValue * backgroundShape.width)
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
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }
        height: units.gu(1.5)
    }

    Image {
        id: thumbShape

        x: backgroundShape.x + backgroundFilledShape.width - (width / 2)
        anchors.verticalCenter: backgroundShape.verticalCenter
        width: thumbWidth
        height: thumbWidth
        source: "artwork/slider_handle.png"
    }
}
