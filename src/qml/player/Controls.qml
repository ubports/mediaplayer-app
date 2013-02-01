import QtQuick 2.0
import Ubuntu.Components 0.1
import QtGraphicalEffects 1.0
import "../sdk"

GenericToolbar {
    id: controls

    property variant video: null
    property alias sceneSelectorHeight : _sceneSelector.height

    signal fullscreenButtonClicked
    signal playbackButtonClicked
    signal seekRequested(int time)

    focus: true
    Component.onCompleted: {
        var result = Theme.loadTheme(Qt.resolvedUrl("../theme/theme.qmltheme"))
    }

    function removeExt(uri) {
        return uri.toString().substring(0, uri.toString().lastIndexOf("."))
    }

    Item {
        id: _contents
        z: 1

        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            opacity: 0.7
            color: "black"
        }

        ListModel {
            id: _sceneSelectorModel
        }

        SharePopover {
            id: _sharePopover

            visible: false

            onVisibleChanged: {
                if (visible) {
                    activityStart("share")
                } else {
                    activityEnd("share")
                }
            }
        }

        Item {
            id: _mainContainer

            anchors.fill: parent
            SceneSelector {
                id: _sceneSelector

                model: _sceneSelectorModel
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: units.gu(2)
                }

                onSceneSelected: {
                    controls.seekRequested(start)
                }

                z: 1
            }

            HLine {
                id: _divLine
                anchors {
                    top: _sceneSelector.bottom
                    topMargin: units.gu(2)
                }
            }

            IconButton {
                id: _fullScreenButton

                iconSource: "artwork/full_scrn_icon.png"
                iconSize: units.gu(3)
                anchors {
                    left: parent.left
                    top: _divLine.bottom
                    topMargin: units.gu(2)
                }
                width: units.gu(9)
                height: units.gu(3)
                onClicked: controls.fullscreenClicked()
            }

            IconButton {
                id: _playbackButtom

                property string icon
                iconSource: icon ? "artwork/%1_icon.png".arg(icon) : ""

                iconSize: units.gu(3)
                anchors {
                    left: _fullScreenButton.right
                    leftMargin: units.gu(9)
                    top: _divLine.bottom
                    topMargin: units.gu(2)
                }
                width: units.gu(9)
                height: units.gu(3)

                onClicked: controls.playbackButtonClicked()
            }

            Item {
                id: _timeLineAnchor

                anchors {
                    left: _playbackButtom.right
                    right: _shareButton.left
                    rightMargin: units.gu(2)
                    top: _divLine.bottom
                    topMargin: units.gu(2)
                }
                height: units.gu(3)

                TimeLine {
                    id: _timeline

                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }

                    width: units.gu(82)
                    minimumValue: 0
                    maximumValue: video ? video.duration / 1000 : 0
                    value: video ? video.position / 1000 : 0
                    onValueChanged: {
                        if (video) {
                            if (Math.abs((video.position / 1000) - value) > 1)  {
                                controls.seekRequested(value * 1000)
                            }

                            _sceneSelector.selectSceneAt(video.position)
                        }
                    }
                }
            }

            IconButton {
                id: _shareButton

                iconSource: "artwork/share_icon.png"
                iconSize: units.gu(3)
                anchors {
                    right: _settingsButton.left
                    top: _divLine.bottom
                    topMargin: units.gu(2)
                }
                width: units.gu(9)
                height: units.gu(3)

                onClicked: {
                    var position = video.position
                    if (position === 0) {
                        if (video.duration > 10000) {
                            position = 10000;
                        } else if (video.duration > 0){
                            position = video.duration / 2
                        }
                    }
                    if (position >= 0) {
                        _sharePopover.picturePath = "image://video/" + video.source + "/" + position;
                    }
                    _sharePopover.caller = _shareButton
                    _sharePopover.show()
                }
            }

            IconButton {
                id: _settingsButton

                iconSource: "artwork/settings_icon.png"
                iconSize: units.gu(3)
                anchors {
                    right: parent.right
                    top: _divLine.bottom
                    topMargin: units.gu(2)
                }

                width: units.gu(9)
                height: units.gu(3)

                onClicked: {
                    controls.clicked()
                }
            }
        }
    }

    Connections {
        target: video
        onDurationChanged: {
            _sceneSelector.currentIndex = -1
            _sceneSelectorModel.clear()
            // Only create thumbnails if video is bigger than 1min
            if (video.duration > 60000) {
                var frameSize = video.duration/10;
                for (var i = 0; i < 10; ++i) {
                    // TODO: discuss this with designers
                    // shift 3s to avoid black frame in the position 0
                    var pos = Math.floor(i * frameSize);
                    _sceneSelectorModel.append({"thumbnail": "image://video/" + video.source + "/" + (pos + 3000),
                                                "start" : pos,
                                                "duration" : frameSize})
                }
            }
        }
    }

    states: [
        State {
            name: "stopped"
            PropertyChanges { target: _playbackButtom; icon: "stop" }
        },

        State {
            name: "playing"
            PropertyChanges { target: _playbackButtom; icon: "play" }
        },

        State {
            name: "paused"
            PropertyChanges { target: _playbackButtom; icon: "pause" }
        }
    ]
}
