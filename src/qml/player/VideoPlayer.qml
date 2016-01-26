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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0 as Popups
import "../common"
import "../sdk"

AbstractPlayer {
    id: player

    property variant nfo
    property int pressCount: 0
    property bool wasPlaying: false
    property string uri
    property bool rotating: false
    property alias controlsActive: _controls.active
    property bool componentLoaded: false
    readonly property int seekStep: 1000
    property var errorDialog: null

    signal timeClicked

    objectName: "player"
    nfo: VideoInfo {
        uri: source
    }

    function playUri(uri) {
        source = uri
        if (componentLoaded) {
            play()
        }
    }

    Component.onCompleted: {
        componentLoaded = true
        if ((state !== "playing") && (source != "")) {
            play()
        }
    }

    function edgeEvent(event) {
        event.accepted = true
    }

    function playPause() {
        if (["paused", "playing"].indexOf(player.state) != -1) {
            player.togglePause();
        } else {
            player.play();
        }
    }

//TODO: blur effect does not work fine without multiple thread rendering
//    ControlsMask {
//        anchors.fill: parent
//        controls: _controls
//        videoOutput: player.videoOutput
//    }

    GenericToolbar {
        id: _controls

        objectName: "toolbar"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: _controlsContents.height

        Controls {
            id: _controlsContents

            property bool isPaused: false

            settingsEnabled: mpApplication.desktopMode

            objectName: "controls"
            state: player.state
            video: player.video
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            maximumHeight: units.gu(27)
            sceneSelectorHeight: units.gu(18)
            playerStatus: player.status

            onPlaybackClicked: player.playPause()

            onFullscreenClicked: {
                if (mpApplication.desktopMode) {
                    mpApplication.toggleFullscreen()
                } else {
                    Qt.quit()
                }
            }

            onSeekRequested: {
                player.video.seek(time)
            }

            onStartSeek: {
                isPaused = (state == "paused")
                player.pause()
            }

            onEndSeek: {
                // Only automatically resume playing after a seek that is not to the
                // end of stream (i.e. position == duration)
                if (player.status != MediaPlayer.EndOfMedia && !isPaused) {
                    player.play()
                }
            }

            onSettingsClicked: {
                if (mpApplication.desktopMode) {
                    var videoFile = mpApplication.chooseFile()
                    if (videoFile != "") {
                        player.stop()
                        item.playUri(videoFile)
                    }
                }
            }
        }
    }

    MouseArea {
        id: _mouseArea

        objectName: "videoMouseArea"
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: _controls.top
        }

        onClicked: _controls.active = !_controls.active
    }

    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Space:
            player.playPause()
            break;
        case Qt.Key_Right:
        case Qt.Key_Left:
        {
            var currentPos = (video ? video.position : 0)
            var nextPos = currentPos
            if (event.key == Qt.Key_Right) {
                var maxPos = (video ? video.duration : 0)
                nextPos += player.seekStep
                if (nextPos > maxPos) {
                    nextPos = -1;
                }
            } else {
                nextPos -= player.seekStep
                if (nextPos < 0) {
                    nextPos = -1
                }
            }

            if (nextPos != -1) {
                player.video.seek(nextPos)
            }
            break;
        }
        case Qt.Key_F11:
            mpApplication.toggleFullscreen()
            break;
        case Qt.Key_Escape:
            mpApplication.leaveFullScreen()
            break;
        default:
            break;
        }
    }

    Component {
        id: dialogPlayerError

        Popups.Dialog {
            id: dialogue
            objectName: "playError"

            property string errorString: ""

            title: i18n.tr("Error playing video")
            text: errorString

            Button {
                text: i18n.tr("Close")
                onClicked: {
                    PopupUtils.close(dialogue)
                    if (player.state != MediaPlayer.PlayingState)
                    {
                        console.debug("Warning: Quitting app due to fatal playback error.")
                        Qt.quit()
                    }
                }
            }

            Component.onDestruction: player.errorDialog = null
        }
    }

    onError: {
        if (player.errorDialog !== null)

            return

        player.errorDialog = PopupUtils.open(dialogPlayerError, null)
        switch(errorCode) {
        case 1:
            player.errorDialog.errorString = i18n.tr("Fail to open the source video.")
            break;
        case 2:
            player.errorDialog.errorString = i18n.tr("Video format not supported.")
            break;
        case 3:
            player.errorDialog.errorString = i18n.tr("A network error occurred.")
            break;
        case 4:
            player.errorDialog.errorString = i18n.tr("You don't have the appropriate permissions to play a media resource.")
            break;
        case 5:
            player.errorDialog.errorString = i18n.tr("Fail to connect with playback backend.")
            break;
        }
    }
}
