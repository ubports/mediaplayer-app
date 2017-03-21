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
import QtQuick.Window 2.2
import QtMultimedia 5.0
import Ubuntu.Components 1.3

Item {
    id: controls

    readonly property string orientation: controls.width >= units.gu(60) ? "LANDSCAPE" : "PORTRAIT"
    property variant video: null
    property int maximumHeight: 0
    property alias sceneSelectorHeight: _sceneSelector.height
    property alias sceneSelectorVisible: _sceneSelector.visible
    property int heightOffset: 0
    property variant playerStatus: MediaPlayer.NoMedia

    property alias finalSeekPosition: _timeline.finalSeekPosition
    property alias openFileEnabled: _openFileButton.enabled

    signal fullscreenClicked
    signal playbackClicked
    signal settingsClicked
    signal openFileClicked
    signal shareClicked
    signal seekRequested(int time)
    signal startSeek
    signal endSeek

    focus: true
    height: sceneSelectorVisible ? maximumHeight - heightOffset : _toolbar.height

    function removeExt(uri) {
        return uri.toString().substring(0, uri.toString().lastIndexOf("."))
    }

    ListModel {
        id: _sceneSelectorModel
    }

    Rectangle {
        id: _bgColor

        color: "black"
        opacity: 0.8
        anchors.fill: parent
    }

    SceneSelector {
        id: _sceneSelector

        property bool show: false

        property bool parentActive: _controls.active

        function selectSceneAt(time) {
            // SKIP it for now, we need to fix hybris bug #1231147
            return
        }

        objectName: "Controls.SceneSelector"
        opacity: 0
        visible: opacity > 0
        // SKIP it for now, we need to fix hybris bug #1231147
        //model: _sceneSelectorModel
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        onSceneSelected: controls.seekRequested(start)
        onParentActiveChanged: {
            if (!parentActive) {
                show = false
            }
        }

        ParallelAnimation {
            id: _showAnimation

            // SKIP it for now, we need to fix hybris bug #1231147
            running: false //_sceneSelector.show
            NumberAnimation { target: _sceneSelector; property: "opacity"; to: 1; duration: 175 }
            NumberAnimation { target: controls; property: "heightOffset"; to: 0; duration: 175 }
        }

        ParallelAnimation {
            id: _hideAnimation

            // SKIP it for now, we need to fix hybris bug #1231147
            running: false //!_sceneSelector.show
            NumberAnimation { target: _sceneSelector; property: "opacity"; to: 0; duration: 175 }
            NumberAnimation { target: controls; property: "heightOffset"; to: units.gu(2); duration: 175 }
        }
    }

    HLine {
        id: _divLine
        anchors {
            left: _toolbar.left
            right: _toolbar.right
            top: parent.top
        }
    }
    Column {
        id: _toolbar

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        Item {
            id: timelinePlaceHolderPortrait

            anchors {
                left: parent.left
                right: parent.right
            }
            height: controls.orientation === "PORTRAIT" ? units.gu(5) : 0
        }

        Row {
            id: controlsRow
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }
            height: units.gu(5)

            IconButton {
                id: _fullScreenButton

                iconSource: Window.visibility ===  Window.FullScreen ? "image://theme/view-restore" : "image://theme/view-fullscreen"
                iconSize: units.gu(3)
                anchors.verticalCenter: parent.verticalCenter
                width: visible ? units.gu(8) : 0
                height: units.gu(4)
                onClicked: controls.fullscreenClicked()
                leftAlignment: true
            }

            VLine {
            }

            IconButton {
                id: playbackButton
                objectName: "Controls.PlayBackButton"

                property string icon

                iconSource: icon ? "image://theme/media-playback-%1".arg(icon) : ""
                iconSize: units.gu(3)
                anchors.verticalCenter: parent.verticalCenter
                width: controls.orientation === "LANDSCAPE" ? units.gu(10) :
                                                              controlsRow.width -
                                                              _fullScreenButton.width -
                                                              _timeLabel.width -
                                                              _shareButton.width -
                                                              _openFileButton.width -
                                                              _quitButton.width

                height: units.gu(4)
                onClicked: controls.playbackClicked()
            }

            VLine {
            }

            Item {
                id: timelinePlaceHolderLandscape

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                width: controls.orientation === "LANDSCAPE" ? controlsRow.width -
                       _fullScreenButton.width -
                       playbackButton.width -
                       _timeLabel.width -
                       _shareButton.width -
                       _openFileButton.width -
                       _quitButton.width : 0

                TimeLine {
                    id: _timeline

                    property bool seeking: false

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                    height: units.gu(4)
                    parent: controls.orientation === "PORTRAIT" ? timelinePlaceHolderPortrait : timelinePlaceHolderLandscape
                    minimumValue: 0
                    maximumValue: video ? video.duration / 1000 : 0

                    // pause the video during the seek
                    onPressedChanged: {
                       if (!pressed && seeking) {
                            endSeek()
                            seeking = false
                       }
                    }

                    // Live value is the real slider value. Ex: User dragging the slider
                    onLiveValueChanged: {
                        if (video)  {
                            var changed = Math.abs(liveValue - videoPosition)
                            if (changed > 1) {
                                if (!seeking) {
                                    startSeek()
                                    seeking = true
                                }
                                seekRequested(liveValue * 1000)
                                _sceneSelector.selectSceneAt(liveValue * 1000)
                             }
                        }
                    }

                    onValueChanged: _sceneSelector.selectSceneAt(video.position)
                    onClicked: {
                        if (insideThumb) {
                            _sceneSelector.show = !_sceneSelector.show
                        } else {
                            _sceneSelector.show = true
                        }
                    }
                }
            }

            VLine {
                visible: controls.orientation === "LANDSCAPE"
            }

            TimeLabel {
                id: _timeLabel

                remainingTime: _timeline.remainingTime
                currentTime: _timeline.currentTime

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: controls.orientation === "LANDSCAPE" ? units.gu(10) : units.gu(8)
            }

            VLine {
                visible: _shareButton.visible
            }

            IconButton {
                id: _shareButton

                /* Disable share button for now until we get some feedback from designers */
                visible: false
                iconSource: "artwork/icon_share.png"
                iconSize: units.gu(3)
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: visible ? units.gu(7) : 0
                onClicked: controls.shareClicked()
            }

            VLine {
                visible: _openFileButton.visible
            }

            IconButton {
                id: _openFileButton

                visible: enabled
                iconSource: "image://theme/document-open"
                iconSize: units.gu(3)
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: visible ? units.gu(7) : 0
                enabled: false
                opacity: enabled ? 1.0 : 0.2
                onClicked: openFileClicked()
            }

            VLine {}

            IconButton {
                id: _quitButton

                iconSource: "image://theme/close"
                iconSize: units.gu(3)
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: units.gu(7)
                onClicked: Qt.quit()
            }
        }
    }

    Connections {
        target: video
        onDurationChanged: {
            _sceneSelector.currentIndex = -1
            _sceneSelectorModel.clear()
            var frameSize = video.duration / 10;
            for (var i = 0; i < 10; ++i) {
                var pos = Math.floor(i * frameSize);
                if (pos <= video.duration) {
                    _sceneSelectorModel.append({"thumbnail": "image://video/" + video.source + "/" + pos,
                                                "start" : pos,
                                                "duration" : frameSize})
                }
             }
        }

        onPositionChanged: {
          // To get position to be smooth and accurate during seeking, do
          // not use the reported value for position from media-hub but instead
          // use the value that the user move the scrubber to. This makes seeking
          // silky smooth. Report correctly on normal advance, or EOS.
          if (!_timeline.seeking || controls.playerStatus == MediaPlayer.EndOfMedia)
            _timeline.videoPosition = video ? video.position / 1000 : 0
        }
    }

    Connections {
        target: controls
        onPlayerStatusChanged: {
            _timeline.playerStatus = controls.playerStatus
        }
    }

    states: [
        State {
            name: "stopped"
            PropertyChanges { target: playbackButton; icon: "start" }
        },

        State {
            name: "playing"
            PropertyChanges { target: playbackButton; icon: "pause" }
        },

        State {
            name: "paused"
            PropertyChanges { target: playbackButton; icon: "start" }
        }
    ]
}
