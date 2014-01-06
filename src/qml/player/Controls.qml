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
import Ubuntu.Components 0.1

Item {
    id: controls

    property variant video: null
    property int maximumHeight: 0
    property alias sceneSelectorHeight: _sceneSelector.height
    property alias sceneSelectorVisible: _sceneSelector.visible
    property int heightOffset: 0

    signal fullscreenClicked
    signal playbackClicked
    signal settingsClicked
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
        opacity: 0.7
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

    Item {
        id: _toolbar
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        height: units.gu(7)

        HLine {
            id: _divLine
            anchors.top: parent.top
        }

        IconButton {
            id: _fullScreenButton

            //TODO: use the correct icon based on window state
            iconSource: "artwork/icon_exitfscreen.png"
            iconSize: units.gu(3)
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: units.gu(9)
            height: units.gu(3)
            onClicked: controls.fullscreenClicked()
        }

        IconButton {
            id: _playbackButtom

            property string icon

            objectName: "Controls.PlayBackButton"
            iconSource: icon ? "artwork/icon_%1.png".arg(icon) : ""
            iconSize: units.gu(3)
            anchors {
                left: _fullScreenButton.right
                // keep proportion btw different resolutions
                leftMargin: units.gu(9) * _toolbar.width / units.gu(128)
                verticalCenter: parent.verticalCenter
            }
            width: units.gu(9)
            height: units.gu(3)

            onClicked: controls.playbackClicked()
        }

        Item {
            id: _timeLineAnchor

            anchors {
                left: _playbackButtom.right
                leftMargin: units.gu(2)
                right: _shareButton.left
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }
            height: units.gu(4)

            // does not show the slider if the space on the screen is not enough
            visible: (width > units.gu(5))

            TimeLine {
                id: _timeline

                property int maximumWidth: units.gu(82)
                property bool seeking: false

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                width: _timeLineAnchor.width >= maximumWidth ? maximumWidth : _timeLineAnchor.width
                minimumValue: 0
                maximumValue: video ? video.duration / 1000 : 0
                value: video ? video.position / 1000 : 0


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
                        var changed = Math.abs(liveValue - value)
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

        IconButton {
            id: _shareButton

            /* Disable share button for now until we get some feedback from designers */
            visible: false
            iconSource: "artwork/icon_share.png"
            iconSize: units.gu(3)
            anchors {
                right: _settingsButton.left
                top: parent.top
                bottom: parent.bottom
            }
            width: units.gu(9)
            height: units.gu(3)

            onClicked: controls.shareClicked()
        }

        IconButton {
            id: _settingsButton

            iconSource: "artwork/icon_settings.png"
            iconSize: units.gu(3)
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            width: units.gu(9)
            height: units.gu(3)
            enabled: false
            opacity: 0.2

            onClicked: settingsClicked()
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
    }

    states: [
        State {
            name: "stopped"
            PropertyChanges { target: _playbackButtom; icon: "play" }
        },

        State {
            name: "playing"
            PropertyChanges { target: _playbackButtom; icon: "pause" }
        },

        State {
            name: "paused"
            PropertyChanges { target: _playbackButtom; icon: "play" }
        }
    ]
}
