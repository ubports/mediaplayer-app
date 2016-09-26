/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import QtTest 1.0
import Ubuntu.Test 0.1

import "../../src/qml/player/"


Item {
    id: root

    width: 800
    height: 600

    visible: true

    // Mock Application object
    QtObject {
        id: mpApplication

        property bool desktopMode: true
    }

    Component {
        id: playerComp

        VideoPlayer {
            id: player
            width: 800
            height: 600
        }
    }

    UbuntuTestCase {
        name: "Date tests"

        property var player: null
        readonly property string videUri: Qt.resolvedUrl("../videos/small.ogg")

        when: windowShown

        function clikPlaybackButton(toolbar)
        {
            var pauseButton = findChild(toolbar, "Controls.PlayBackButton")
            //WORKAROUND: mouseClick(pauseButton) fails on vivid
            mouseClick(player, pauseButton.x + (pauseButton.width / 2), player.height - (pauseButton.height / 2))
        }


        function init()
        {
            player = playerComp.createObject(root, {})
            waitForRendering(player)
        }

        function cleanup()
        {
            player.destroy()
            player = null
        }

        function test_player_init()
        {
            tryCompare(player, 'paused', false)
            tryCompare(player, 'playing', false)
            tryCompare(player, 'wasPlaying', false)
        }

        function test_open_video()
        {
            player.playUri(videUri)
            tryCompare(player, 'paused', false)
            tryCompare(player, 'playing', true)
        }

        function test_play_pause_video()
        {
            player.playUri(videUri)
            tryCompare(player, 'playing', true)
            player.playPause()
            tryCompare(player, 'paused', true)
            player.playPause()
            tryCompare(player, 'paused', false)
        }

        function test_click_to_show_and_hide_controls()
        {
            player.playUri(videUri)
            tryCompare(player, 'playing', true)

            mouseClick(player)
            tryCompare(player, 'controlsActive', true)

            mouseClick(player)
            tryCompare(player, 'controlsActive', false)
        }

        function test_pause_button()
        {
            // play video
            player.playUri(videUri)
            tryCompare(player, 'playing', true)

            var toolbar = findChild(player, "toolbar")
            tryCompare(toolbar, 'fullVisible', false)

            // show controls
            mouseClick(player)
            tryCompare(player, 'controlsActive', true)
            tryCompare(toolbar, 'fullVisible', true)
            tryCompare(player, 'paused', false)

            // click to pause
            clikPlaybackButton(toolbar)
            tryCompare(player, 'paused', true)
        }


        function test_play_after_pause()
        {
            // play video
            var toolbar = findChild(player, "toolbar")
            player.playUri(videUri)
            tryCompare(player, 'playing', true)

            // show controls
            mouseClick(player)
            tryCompare(player, 'controlsActive', true)
            tryCompare(toolbar, 'fullVisible', true)

            // click to pause
            clikPlaybackButton(toolbar)
            tryCompare(player, 'paused', true)

            clikPlaybackButton(toolbar)
            tryCompare(player, 'paused', false)
        }
    }
}
