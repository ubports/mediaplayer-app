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

ListView {
    id: _sceneList

    signal sceneSelected(int start, int duration)

    orientation: ListView.Horizontal

    delegate: SceneFrame {
        active: (currentIndex == index)
        start: model.start
        duration: model.duration
        source: model.thumbnail

        width: active ? units.gu(26) : units.gu(19)
        height: _sceneList.height

        onClicked: {
            currentIndex = index
            sceneSelected(start, duration)
        }
    }

    function selectSceneAt(time) {
        if (time <= 0) {
            currentIndex = -1;
        }

        if (currentItem) {
            if ((time >= currentItem.start) &&
                (time <= (currentItem.start + currentItem.duration))) {
                return
            }
        }

        console.debug("Scenelist count:  " + _sceneList.count)
        console.debug("Select at: " + time)

        for(var index = 0; index < _sceneList.model.count; index++) {
            var item = _sceneList.model.get(index)
            if (item) {
                console.debug("Start: "  + item.start)
                console.debug("End: "  + (item.start + item.duration))
                if ((time >= item.start) &&
                    (time <= (item.start + item.duration))) {
                    currentIndex = index
                    return;
                }
            }
        }
        console.debug("Invalid scene time: " + time)
        currentIndex = -1
    }
}
