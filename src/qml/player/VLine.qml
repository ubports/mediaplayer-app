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

Row {
    id: root

    anchors {
        top: parent.top
        topMargin: units.gu(0.5)
        bottom: parent.bottom
        bottomMargin: units.gu(0.5)
    }
    width: visible ? units.dp(2) : 0

    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        color: "white"
        opacity: 0.08
        width: root.visible ? units.dp(1) : 0
    }
    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        color: "black"
        opacity: 0.03
        width: root.visible ? units.dp(1) : 0
    }
}
