import QtQuick 1.0
import QtMultimediaKit 1.1
import "../common"
import "../common/utils.js" as Utils

FocusScope {
    property bool playing: state == "playing"
    property bool paused: state == "paused"
    property real aspectRatio: width / height
    property variant video: video

    property alias source: video.source
    property alias status: video.status
    property alias volume: video.volume

    property int forwardSeekStep: Math.min(60000, video.duration * 0.05)
    property int backwardSeekStep: Math.min(30000, video.duration * 0.025)

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
        if (video.seekable) {
            if (state != "playing" && state != "paused") {
                state = "playing"
                state = "paused"
            }
            video.position += value
        } else {
            return false
        }
        return true
    }

    function fastForward() {
        if (video.seekable) {
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
        if (video.seekable) {
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

    Video {
        property real aspectRatio: metaData.resolution !== undefined ? metaData.resolution.width / metaData.resolution.height : -1
        property int realWidth: aspectRatio != -1 ? Math.min(width, (aspectRatio >= parent.aspectRatio ? width : aspectRatio * height)) : -1
        property int realHeight: aspectRatio != -1 ? Math.min(height, (aspectRatio < parent.aspectRatio ? height : width / aspectRatio)) : -1
        property int widthMargin: aspectRatio != -1 ? (aspectRatio >= parent.aspectRatio ? 0 : (width - realWidth) / 2) : -1
        property int heightMargin: aspectRatio != -1 ? (aspectRatio < parent.aspectRatio ? 0 : (height - realHeight) / 2) : -1
        id: video
        anchors.fill: parent
        smooth: true

        /* FIXME that's a workaround for not resetting the video surface */
        onStatusChanged: if (status == Video.Buffered) opacity = 1
        onSourceChanged: { if (source == "") opacityTimer.restart(); else opacityTimer.stop() }

        Timer {
            id: opacityTimer
            interval: 500
            onTriggered: video.opacity = 0
        }

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        onError: {
            console.log("Video: " + video.errorString)
        }
    }

    Timer {
        id: scrubbingTimer
        interval: 500
        repeat: true

        property int step

        onTriggered:
            if (video.position + step < 0) {
                video.position = 0
                player.state = "playing"
            } else {
                video.position += step
            }
    }

    states: [
        State {
            name: "stopped"
            PropertyChanges { target: video; playing: false; paused: false }
            PropertyChanges { target: scrubbingTimer; running: false }
        },

        State {
            name: "playing"
            PropertyChanges { target: video; playing: true; paused: false; playbackRate: 1.0; muted: false}
            PropertyChanges { target: scrubbingTimer; running: false }
        },

        State {
            name: "paused"
            PropertyChanges { target: video; playing: true; paused: true }
            PropertyChanges { target: scrubbingTimer; running: false }
        },

        State {
            name: "forwarding"
            PropertyChanges { target: video; playing: true; paused: true; muted: true }
            PropertyChanges { target: scrubbingTimer; running: true }
        },

        State {
            name: "rewinding"
            PropertyChanges { target: video; playing: true; paused: true; muted: true }
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
