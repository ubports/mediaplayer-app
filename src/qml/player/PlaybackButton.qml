/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

IconButton {
    property string icon
    readonly property string _iconPath: "artwork/icon_%1.png"
    readonly property string _selectedIconPath: "artwork/icon_%1_orange.png"

    iconSource: {
        if (icon) {
            if (state == "selected") {
                return _selectedIconPath.arg(icon)
            } else {
                return _iconPath.arg(icon)
            }
        } else {
            return ""
        }
    }
}
