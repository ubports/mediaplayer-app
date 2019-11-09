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
import QtQuick 2.4
import QtMultimedia 5.0
import "../common"
import "../common/utils.js" as Utils

Item {
    id: player

    property bool playing: state == "playing"
    property bool paused: state == "paused"
    property real aspectRatio: width / height
    property variant video: mediaPlayer
    property alias videoOutput: _videoOutput

    property alias source: mediaPlayer.source
    property alias status: mediaPlayer.status
    property alias volume: mediaPlayer.volume

    readonly property alias duration: mediaPlayer.duration
    readonly property alias position: mediaPlayer.position

    property int forwardSeekStep: Math.min(60000, mediaPlayer.duration * 0.05)
    property int backwardSeekStep: Math.min(30000, mediaPlayer.duration * 0.025)


    signal error(int errorCode, string errorString)

    objectName: "videoPlayer"
    state: "stopped"

    function stop() {
        console.log("DX as.stop")
        state = "stopped"
    }

    function startPlaying() {
        console.log("DX ap.startPlaying")
	    play()
        startPlayingSeekPositionTimer.running = true
    }

    Timer {
        id: startPlayingSeekPositionTimer
        interval: 2000
        repeat: false
        running: false
        onTriggered: {
            mediaPlayer.seek(120000)
        }
    }

    function play() {
        console.log("DX ap.play")
        state = "playing"
    }

    function pause() {
        console.log("DX ap.pause")
        state = "paused"
    }

    function togglePause() {
        console.log("DX ap.tp")
        if (playing) {
            pause()
        } else if (paused) {
            play()
        }
    }

    function seekForward() {
        return seekRelative(forwardSeekStep)
    }

    function seekBackward() {
        return seekRelative(-backwardSeekStep)
    }

    function seekRelative(value) {
        console.log("DX ap.s ", value, state)
        if (mediaPlayer.seekable) {
            //if (state != "playing" && state != "paused") {
	    //   console.log("DX ap.s toggle state playing/paused")
            //    state = "playing"
            //    state = "paused"
            //}
            mediaPlayer.seek(mediaPlayer.position + value)
        } else {
            return false
        }
        return true
    }

    function fastForward() {
        if (mediaPlayer.seekable) {
            if (state == "forwarding") {
                scrubbingTimer.step = Math.min(5 * forwardSeekStep, scrubbingTimer.step * 1.5)
            } else {
                state = "forwarding"
            }
            return true
        } else {
            return false
        }
    }

    function rewind() {
        console.log("DX ap.rewind")
        if (mediaPlayer.seekable) {
            if (state == "rewinding") {
                scrubbingTimer.step = Math.max(-5 * forwardSeekStep, scrubbingTimer.step * 1.5)
            } else {
                state = "rewinding"
            }
            return true
        } else {
            return false
        }
    }

    VideoOutput {
        id: _videoOutput

        source: mediaPlayer
        anchors.fill: parent
        smooth: true

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
    }

    MediaPlayer {
        id: mediaPlayer

        property real aspectRatio: metaData.resolution !== undefined ? metaData.resolution.width / metaData.resolution.height : -1
        property int realWidth: aspectRatio != -1 ? Math.min(width, (aspectRatio >= parent.aspectRatio ? width : aspectRatio * height)) : -1
        property int realHeight: aspectRatio != -1 ? Math.min(height, (aspectRatio < parent.aspectRatio ? height : width / aspectRatio)) : -1
        property int widthMargin: aspectRatio != -1 ? (aspectRatio >= parent.aspectRatio ? 0 : (width - realWidth) / 2) : -1
        property int heightMargin: aspectRatio != -1 ? (aspectRatio < parent.aspectRatio ? 0 : (height - realHeight) / 2) : -1

        onError: {
            console.error("AbstractPlayer: " + error + ":" + errorString)
            player.error(error, errorString)
        }

        onPlaybackStateChanged: {
            // Make sure that the app toggles the play/pause button when playbackStatus
            // changes from underneath it in media-hub/qtubuntu-media
            if (mediaPlayer.playbackState == MediaPlayer.PausedState) {
                player.pause()
            } else if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                player.play()
            }
        }
    }

    Timer {
        id: scrubbingTimer
        interval: 500
        repeat: true

        property int step

        onTriggered: {
            console.log("DX ap.st.ot")
            if (mediaPlayer.position + step < 0) {
                mediaPlayer.seek(0)
                player.state = "playing"
            } else {
                mediaPlayer.seek(mediaPlayer.position + step)
            }
        }
    }

    states: [
        State {
            name: "stopped"
            StateChangeScript { script: mediaPlayer.stop() }
            PropertyChanges { target: scrubbingTimer; running: false }
        },

        State {
            name: "playing"
            PropertyChanges { target: mediaPlayer; playbackRate: 1.0; muted: false }
            StateChangeScript { script: mediaPlayer.play() }
            PropertyChanges { target: scrubbingTimer; running: false }
        },

        State {
            name: "paused"
            StateChangeScript { script: mediaPlayer.pause() }
            PropertyChanges { target: scrubbingTimer; running: false }
        },

        State {
            name: "forwarding"
            PropertyChanges { target: mediaPlayer; muted: true }
            StateChangeScript { script: mediaPlayer.pause() }
            PropertyChanges { target: scrubbingTimer; running: true }
        },

        State {
            name: "rewinding"
            PropertyChanges { target: mediaPlayer; muted: true }
            StateChangeScript { script: mediaPlayer.pause() }
            PropertyChanges { target: scrubbingTimer; running: true }
        }
    ]

    transitions: [
        Transition {
            to: "forwarding"
            PropertyAction { target: scrubbingTimer; property: "step"; value: forwardSeekStep }
        },

        Transition {
            to: "rewinding"
            PropertyAction { target: scrubbingTimer; property: "step"; value: -forwardSeekStep }
        }
    ]
}
