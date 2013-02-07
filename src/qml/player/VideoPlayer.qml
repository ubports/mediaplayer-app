/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
 *  Michał Sawicz <michal.sawicz@canonical.com>
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
import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 0.1
import "../common"
import "../sdk"

AbstractPlayer {
    id: player

    property variant nfo
    property int pressCount: 0
    property bool wasPlaying: false
    property string uri
    property bool rotating: false

    signal timeClicked

    nfo: VideoInfo {
        uri: source
    }

    function playUri(uri) {
        source = uri
        play()
    }

    function edgeEvent(event) {
        event.accepted = true
    }

//TODO: blur effect does not work fine without multiple thread rendering
//    ControlsMask {
//        anchors.fill: parent
//        controls: _controls
//        videoOutput: player.videoOutput
//    }

    GenericToolbar {
        id: _controls


        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(29)

        Controls {

            property bool isPaused: false

            state: player.state
            video: player.video
            anchors.fill:  parent
            sceneSelectorHeight: units.gu(18)

            onPlaybackButtonClicked: {
                if (["paused", "playing"].indexOf(state) != -1) {
                    player.togglePause()
                } else {
                    player.play()
                }
            }

            onFullscreenButtonClicked: {
                //TODO: wait for shell supports fullscreen
            }

            onSeekRequested: {
                player.video.seek(time)
            }

            onStartSeek: {
                isPaused = (state == "paused")
                player.pause()
            }

            onEndSeek: {
                if (!isPaused) {
                    player.play()
                }
            }
        }
    }

    Label {
        id: title

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: _controls.top
        }

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: player.paused ? 1 : 0
        fontSize: "x-large"
        color: "white"
        fontSizeMode: Text.Fit
        elide: {
            if (player.nfo.video || video.metaData.title !== undefined) return Text.ElideMiddle
            else return Text.ElideLeft
        }
        text: {
            if (player.nfo.video) return player.nfo.video.title
            else if (video.metaData.title !== undefined) return video.metaData.title
            else return video.source.toString().replace(/.*\//, '')
        }
        Behavior on opacity { NumberAnimation {} }
    }

    MouseArea {
        id: _mouseArea

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: _controls.top
        }

        onClicked: {
            if (_controls.active) {
                _controls.active = false
            }
        }
    }
}
