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

AbstractButton {
    id: root

    property alias iconSource: _image.source
    property alias iconSize: _image.height
    property bool leftAlignment: false

    focus: false

    Image {
        id: _image

        width: height
        smooth: true
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: root.leftAlignment ? undefined : parent.horizontalCenter
            left: root.leftAlignment ? parent.left : undefined
        }
    }
}
