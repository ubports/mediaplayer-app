import QtQuick 2.0
import Ubuntu.Components 0.1
import "../sdk"

FocusScope {
    id: controls

    property variant video: null
    property bool shown: false
    property alias sceneSelectorHeight : _sceneSelector.height

    signal activityStart(string activity)
    signal activityEnd(string activity)
    signal clicked
    signal playbackButtonClicked

    focus: true

    Component.onCompleted: {
        var result = Theme.loadTheme(Qt.resolvedUrl("../theme/theme.qmltheme"))
        console.debug("Theme loaded:" + result + " " + Theme.error)
    }

    function removeExt(uri) {
        return uri.toString().substring(0, uri.toString().lastIndexOf("."))
    }

    function close() {
        console.log("WARNING: Controls.close() unimplemented")
    }

    function previous() {
        sceneSelector.previous()
    }

    function next() {
        sceneSelector.next()
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

            onMovementStarted: controls.clicked()
            onSceneSelected: {
                clicked()
                video.seek(start)
            }
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
                bottom: parent.bottom
            }
            width: units.gu(9)
            onClicked: Qt.quit()
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
                bottom: parent.bottom
            }
            width: units.gu(9)

            onClicked: {
                controls.clicked()
                controls.playbackButtonClicked()
            }
        }

        TimeLine {
            id: _timeline

            anchors {
                left: _playbackButtom.right
                right: _shareButton.left
                rightMargin: units.gu(7)
                top: _divLine.bottom
                topMargin: units.gu(2)
                bottom: parent.bottom
                bottomMargin: units.gu(2)
            }

            minimumValue: 0
            maximumValue: video.duration / 1000
            value: video.position / 1000
            onValueChanged: {
                _sceneSelector.selectSceneAt(video.position)
            }
        }

        IconButton {
            id: _shareButton

            iconSource: "artwork/share_icon.png"
            iconSize: units.gu(3)
            anchors {
                right: _settingsButton.left
                top: _divLine.bottom
                bottom: parent.bottom
            }
            width: units.gu(9)

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
                controls.clicked()
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
                bottom: parent.bottom
            }

            width: units.gu(9)

            onClicked: {
                controls.clicked()
            }
        }
    }

    Rectangle {
        color: "black"
        opacity: 0.7
        anchors.fill: _mainContainer
        z: -1
    }

    Timer {
        id: _idlePopulateThumbnail
        interval: 5000
        running: false
        repeat: false
        onTriggered: {
            console.debug("Populate thumbnail nowwww.")
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

    Connections {
       target: video
       onDurationChanged: {
           _sceneSelector.currentIndex = -1
           _sceneSelectorModel.clear()
           _idlePopulateThumbnail.restart()
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
        },

        State {
            name: "forwarding"
            PropertyChanges { target: _playbackButtom; icon: "forward" }
        },

        State {
            name: "rewinding"
            PropertyChanges { target: _playbackButtom; icon: "rewind" }
        }
    ]
}
