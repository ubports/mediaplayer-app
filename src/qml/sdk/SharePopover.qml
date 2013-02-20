/*
 * Copyright (C) 2011-2013 Canonical Ltd
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
 */

import QtQuick 2.0
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
//import "../../Capetown/Widgets"

Popover {
    id: sharePopover

    property alias picturePath : shareMenu.picturePath

    ShareMenu {
        id: shareMenu
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        onSelected: sharePopover.hide()
    }
}
