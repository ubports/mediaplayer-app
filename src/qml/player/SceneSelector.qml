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

ListView {
    id: _sceneList

    signal sceneSelected(int start, int duration)

    orientation: ListView.Horizontal

    delegate: SceneFrame {
        objectName: "SceneSelector.Scene" + index
        active: (currentIndex == index)
        start: model.start
        duration: model.duration
        source: model.thumbnail

        width: active ? units.gu(27) : units.gu(20)
        anchors {
            top: parent.top
            topMargin: units.gu(2)
            bottom: parent.bottom
        }

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

        for(var index = 0; index < _sceneList.model.count; index++) {
            var item = _sceneList.model.get(index)
            if (item) {
                if ((time >= item.start) &&
                    (time <= (item.start + item.duration))) {
                    currentIndex = index
                    return;
                }
            }
        }
        currentIndex = -1
    }
}
