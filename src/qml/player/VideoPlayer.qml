import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 0.1
import "../common"
import "../common/visibilityBehaviors"
import "../common/units.js" as Units

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

    Controls {
        id: _controls

        state: player.state
        video: player.video
        height: units.gu(29)
        sceneSelectorHeight: units.gu(18)
        anchors {
            left: parent.left
            right: parent.right
        }

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
    }

    Label {
        id: title

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -_controls.height / 2
        }

        horizontalAlignment: Text.AlignHCenter
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
}
