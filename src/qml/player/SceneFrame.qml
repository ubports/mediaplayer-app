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

MouseArea {
    id: _imageFrame

    property int start
    property int duration
    property alias source: _image.source
    property bool active: false
    readonly property bool ready: (_image.status === Image.Ready)

    Behavior on width {
        NumberAnimation { duration: 150; easing.type: Easing.InOutQuart }
    }

    UbuntuShape {
        id: _shape
        radius: "medium"

        anchors {
            fill: parent
            topMargin: active ? 0 : units.gu(2)
            bottomMargin: active ? 0 : units.gu(2)
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)

            Behavior on topMargin {
                NumberAnimation { duration: 150; easing.type: Easing.InOutQuart }
            }

            Behavior on bottomMargin {
                NumberAnimation { duration: 150; easing.type: Easing.InOutQuart }
            }
        }

        image: Image {
            id: _image

            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            sourceSize.width: _shape.width
            sourceSize.height: _shape.height
        }
    }

    ActivityIndicator {
        id: imgLoading

        anchors {
            verticalCenter: _shape.verticalCenter
            horizontalCenter: _shape.horizontalCenter
            margins: units.gu(0.5)
        }

        running: _image.status != Image.Ready
        visible: running
    }
}
