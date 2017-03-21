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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0 as Popups
import "../common"
import "../sdk"

AbstractPlayer {
    id: player

    property variant info
    property int pressCount: 0
    property bool wasPlaying: false
    property bool rotating: false
    property alias controlsActive: _controls.active
    property bool componentLoaded: false
    readonly property int seekStep: 1000
    readonly property bool isEmpty: source == ""
    property var errorDialog: null

    signal timeClicked
    signal playEmptyFile

    objectName: "player"
    info: VideoInfo {
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


    ToolBar {
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

            property bool wasPausedBeforeSeek: false
            property bool wasVisibleBeforeSeek: false
            property int seekPosition: 0

            function aboutToSeek()
            {
                wasPausedBeforeSeek = (state == "paused")
                wasVisibleBeforeSeek = _controls.active && !_controls.aboutToDismiss
                _controls.abortDismiss()
                player.pause()
                _controls.active = true
                _controlsContents.seekPosition = video.position
            }

            function seekDone()
            {
                _controlsContents.finalSeekPosition = _controlsContents.seekPosition
                // Only automatically resume playing after a seek that is not to the
                // end of stream (i.e. position == duration)
                if (player.status !== MediaPlayer.EndOfMedia && !_controlsContents.wasPausedBeforeSeek) {
                    player.play()
                }

                if (!_controlsContents.wasVisibleBeforeSeek) {
                    _controls.dismiss()
                }

                _controlsContents.seekPosition = -1
                _controlsContents.wasPausedBeforeSeek = false
                _controlsContents.wasVisibleBeforeSeek = false
            }

            function seek(time)
            {
                //keep trak of last seek position in case of the last seek does not complete in time
                //sometimes the seek is too fast and we can not rely on the video position to calculate
                //the next seek position.
                _controlsContents.seekPosition = time
                player.video.seek(time)
            }

            openFileEnabled: true
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

            onPlaybackClicked: {
                if (player.source == "") {
                    player.playEmptyFile()
                } else {
                    player.playPause()
                }
            }

            onFullscreenClicked: mpApplication.toggleFullscreen()
            onOpenFileClicked: player.playEmptyFile()
            onStartSeek: aboutToSeek()
            onEndSeek: seekDone()
            onSeekRequested: seek(time)
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

    Item {
        id: emptyState

        anchors.fill: parent
        visible: false
        Icon {
            id: emptyStateIcon

            source: "image://theme/document-open"
            color: "white"
            anchors.centerIn: parent
            width: units.gu(4)
        }
        Label {
            text: i18n.tr("Please choose a file to open")
            color: "white"
            textSize: Label.Large
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: emptyStateIcon.bottom
                topMargin: units.gu(2)
            }
        }
    }

    state: player.isEmpty ? "empty" : ""
    states: [
        State {
            name: "empty"
            PropertyChanges {
                target:  _controls
                active: true
            }
            PropertyChanges {
                target: emptyState
                visible: true
            }
            PropertyChanges {
                target: _mouseArea
                enabled: false
            }
        }

    ]

    Keys.onReleased:
    {
        if (event.isAutoRepeat) {
            return
        }

        switch(event.key) {
            case Qt.Key_Right:
            case Qt.Key_Left:
                _controlsContents.seekDone()
                break;
            default:
                break
        }
    }

    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Space:
            player.playPause()
            break;
        case Qt.Key_Right:
        case Qt.Key_Left:
        {
            if (!event.isAutoRepeat) {
                _controlsContents.aboutToSeek()
            }
            // wait controls be fully visbile
            if (!_controls.fullVisible)
                return

            var nextPos = _controlsContents.seekPosition >=  0 ?
                        _controlsContents.seekPosition : 0

            if (event.key === Qt.Key_Right) {
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

            if (nextPos !== -1) {
                _controlsContents.seek(nextPos)
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
