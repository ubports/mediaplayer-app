import QtQuick 2.0
import QtMultimedia 5.0
import "../common"
import "../common/utils.js" as Utils

FocusScope {
    property bool playing: state == "playing"
    property bool paused: state == "paused"
    property real aspectRatio: width / height
    property variant video: mediaPlayer

    property alias source: mediaPlayer.source
    property alias status: mediaPlayer.status
    property alias volume: mediaPlayer.volume

    property int forwardSeekStep: Math.min(60000, mediaPlayer.duration * 0.05)
    property int backwardSeekStep: Math.min(30000, mediaPlayer.duration * 0.025)

    id: player
    state: "stopped"

    function stop() {
        state = "stopped"
        source = ""
    }

    function play() {
        state = "playing"
    }

    function pause() {
        state = "paused"
    }

    function togglePause() {
        if (playing) {
            pause()
        } else if (paused) {
            play()
        }
    }

    function seekForward() {
        return seek(forwardSeekStep)
    }

    function seekBackward() {
        return seek(-backwardSeekStep)
    }

    function seek(value) {
        if (mediaPlayer.seekable) {
            if (state != "playing" && state != "paused") {
                state = "playing"
                state = "paused"
            }
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

    Rectangle {
        id: playerBackground
        anchors.fill: parent
        color: "black"
    }

//    Video {

//        id: video

//        /* FIXME that's a workaround for not resetting the video surface */
//        onStatusChanged: if (status == Video.Buffered) opacity = 1
//        onSourceChanged: { if (source == "") opacityTimer.restart(); else opacityTimer.stop() }

//        Timer {
//            id: opacityTimer
//            interval: 500
//            onTriggered: video.opacity = 0
//        }
//    }

    VideoOutput {
        id: videoOutput
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
            console.log("AbstractPlayer: " + errorString)
        }
    }

    Timer {
        id: scrubbingTimer
        interval: 500
        repeat: true

        property int step

        onTriggered:
            if (mediaPlayer.position + step < 0) {
                mediaPlayer.seek(0)
                player.state = "playing"
            } else {
                mediaPlayer.seek(mediaPlayer.position + step)
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
