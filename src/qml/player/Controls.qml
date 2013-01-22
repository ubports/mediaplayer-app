import QtQuick 2.0
import Ubuntu.Components 0.1
import "../sdk"

FocusScope {
    id: controls

    property variant video: null
    property variant button: button
    property bool shown: false

    signal activityStart(string activity)
    signal activityEnd(string activity)
    signal clicked
    signal playbackButtonClicked
    signal timeClicked

    focus: true

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

    SceneSelector {
        id: _sceneSelector

        model: _sceneSelectorModel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: mainContainer.top
        anchors.bottomMargin: units.gu(2)

        onMovementStarted: controls.activated()

        onSceneSelected: {
            clicked()
            video.seek(start)
        }
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

    Rectangle {
        id: mainContainer

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "black"
        opacity: 0.7
        height: units.gu(3)

        IconButton {
            id: _closeButton

            iconSource: "artwork/icon_close.png"
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: units.gu(3)
            onClicked: Qt.quit()
        }

        VLine {
            id: _vline1

            anchors.left: _closeButton.right
        }

        PlaybackButton {
            id: _playbackButtom

            anchors.left: _vline1.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: units.gu(3)

            onClicked: {
                controls.clicked()
                controls.playbackButtonClicked()
            }
        }

        VLine {
            id: _vline2

            anchors.left: _playbackButtom.right
        }

        TimeLine {
            id: _timeline

            anchors.left: _vline2.right
            anchors.right: _vline3.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            minimumValue: 0
            maximumValue: video.duration / 1000
            value: video.position / 1000
            onValueChanged: {
                _sceneSelector.selectSceneAt(video.position)
            }
        }

        VLine {
            id: _vline3

            anchors.right: _shareButton.left
        }

        IconButton {
            id: _shareButton

            iconSource: "artwork/icon_share.png"
            anchors.right: _vline4.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: units.gu(3)

            onClicked: {
                _sharePopover.caller = _shareButton
                _sharePopover.show()
            }
        }

        VLine {
            id: _vline4

            anchors.right: _settingsButton.left
        }

        IconButton {
            id: _settingsButton

            iconSource: "artwork/icon_settings.png"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: units.gu(3)

            onClicked: {
                controls.clicked()
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
                   _sceneSelectorModel.append({"thumbnail": "image://video/" + video.source + "/"+ (pos + 3000),
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
