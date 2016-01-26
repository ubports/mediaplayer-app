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
import QtGraphicalEffects 1.0


Item {
    id: _controlsMask

    property variant controls
    property variant videoOutput

    LinearGradient {
        id: _mask

        anchors.fill: parent
        start: Qt.point(0, controls.y)
        end: Qt.point(0, controls.y + controls.height)
        visible: false

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00ffffff" }
            GradientStop { position: 0.1; color: "#000000" }
        }
    }

    MaskedBlur {
        anchors.fill: parent
        source: videoOutput
        maskSource: _mask
        radius: 99
        samples: 39
        fast: true
    }
}
