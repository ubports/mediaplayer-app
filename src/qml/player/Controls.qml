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
import Ubuntu.Components 1.1

Item {
    id: controls

    readonly property string orientation: controls.width >= units.gu(60) ? "LANDSCAPE" : "PORTRAIT"
    property variant video: null
    property int maximumHeight: 0
    property alias sceneSelectorHeight: _sceneSelector.height
    property alias sceneSelectorVisible: _sceneSelector.visible
    property int heightOffset: 0

    property alias settingsEnabled: _settingsButton.enabled

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
            id: timelinePlaceHolder

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
            }
            height: units.gu(5)
            spacing: units.gu(2)

            IconButton {
                id: _fullScreenButton

                //TODO: use the correct icon based on window state
                iconSource: mpApplication.desktopMode ? "artwork/icon_exitfscreen.png" : "image://theme/back"
                iconSize: units.gu(3)
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(7)
                height: units.gu(4)
                onClicked: controls.fullscreenClicked()
            }

            VLine {
            }

            IconButton {
                id: _playbackButtom
                objectName: "Controls.PlayBackButton"

                property string icon

                iconSource: icon ? "image://theme/media-playback-%1".arg(icon) : ""
                iconSize: units.gu(3)
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(7)
                height: units.gu(4)
                onClicked: controls.playbackClicked()
            }

            VLine {
            }

            TimeLine {
                id: _timeline

                property bool seeking: false

                anchors.verticalCenter: parent.verticalCenter
                parent: controls.orientation === "PORTRAIT" ? timelinePlaceHolder : controlsRow
                width: controls.orientation === "PORTRAIT" ? parent.width :
                       controlsRow.width -
                       _fullScreenButton.width -
                       _playbackButtom.width -
                       _timeLabel.width -
                       _shareButton.width -
                       _settingsButton.width -
                       (controlsRow.spacing * (controlsRow.children.length - 4))
                height: units.gu(5)
                minimumValue: 0
                maximumValue: video ? video.duration / 1000 : 0
                videoPosition: video ? video.position / 1000 : 0

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

            VLine {}

            TimeLabel {
                id: _timeLabel

                remainingTime: _timeline.remainingTime
                currentTime: _timeline.currentTime

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: units.gu(10)
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
                width: visible ? units.gu(4) : 0
                onClicked: controls.shareClicked()
            }

            VLine {
                visible: _settingsButton.visible
            }

            IconButton {
                id: _settingsButton

                visible: false
                iconSource: "artwork/icon_settings.png"
                iconSize: units.gu(3)
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: visible ? units.gu(9) : 0
                enabled: false
                opacity: enabled ? 1.0 : 0.2
                onClicked: settingsClicked()
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
    }

    states: [
        State {
            name: "stopped"
            PropertyChanges { target: _playbackButtom; icon: "start" }
        },

        State {
            name: "playing"
            PropertyChanges { target: _playbackButtom; icon: "pause" }
        },

        State {
            name: "paused"
            PropertyChanges { target: _playbackButtom; icon: "start" }
        }
    ]
}
