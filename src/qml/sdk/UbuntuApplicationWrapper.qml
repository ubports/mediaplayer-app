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
import Ubuntu.Application 0.1

Item {
    function switchToShareApplication() {
        console.log("Launching the share application.");
        ApplicationManager.focusFavoriteApplication(ApplicationManager.ShareApplication);
    }

    function switchToCameraApplication() {
        console.log("Launching the camera application.");
        ApplicationManager.focusFavoriteApplication(ApplicationManager.CameraApplication);
    }
}
