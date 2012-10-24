import QtQuick 2.0
import QtMultimedia 5.0
import "../common"
import "../common/visibilityBehaviors"
import "../sidebar"
import "../common/units.js" as Units

AbstractPlayer {
    id: player

    property variant nfo
    property int pressCount: 0
    property bool wasPlaying: false
    property string uri

    nfo: VideoInfo {
        uri: source
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (!controls.focus) controls.focus = true; else { controls.close(); }
    }

    VideoPlayerIndicatorsBar {
        id: indicators
        anchors.right: parent.right
        anchors.left: parent.left
        y: indicatorsVisibility.shown ? 0 : -height

        height: Units.tvPx(122)

        Keys.onEscapePressed: {
            focus = false
            player.forceActiveFocus()
        }

        Keys.forwardTo: [indicatorsBehavior]
        onFocusedIndicatorChanged: indicatorsBehavior.restartTimer()

        Connections {
            target: indicators.focusedIndicator
            onActiveChanged: {
                if (indicators.focusedIndicator.active) indicatorsVisibility.beginForceVisible("indicators")
                else indicatorsVisibility.endForceVisible("indicators")
            }
        }
    }

    TimeoutBehavior {
        id: indicatorsBehavior
        target: indicators
        forcedVisible: indicatorsVisibility.forceVisible
    }

    VisibilityController {
        id: indicatorsVisibility
        behavior: indicatorsBehavior
        onShownChanged: if (!shown && indicators.activeFocus) {
            indicators.focus = false
            player.forceActiveFocus()
        }
    }

    function playUri(uri) {
        source = uri
        play()
    }

    Keys.onPressed: {
        event.accepted = true
        if (event.key == Qt.Key_F3 || event.key == Qt.Key_MediaPlay) {
            if (!sidebar.activeFocus) {
                sidebar.forceActiveFocus()
            } else {
                sidebar.focus = false
                player.forceActiveFocus()
            }
        } else if (!event.isAutoRepeat && (event.key == Qt.Key_F2 || event.key == Qt.Key_Period ||
                                           (event.key == Qt.Key_R && event.modifiers & Qt.ControlModifier))) {
            if (!indicators.activeFocus) {
                indicators.forceActiveFocus()
            } else {
                indicators.focus = false
                player.forceActiveFocus()
            }
        } else if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) {
            controls.focus = true
            if (event.isAutoRepeat) {
                pressCount += 1
            } else {
                wasPlaying = player.playing
                pressCount = 1
            }
        } else if (!event.isAutoRepeat && event.key == Qt.Key_MediaStop || event.key == Qt.Key_Escape) {
            player.stop()
        } else if (event.key == Qt.Key_Return) {
            controls.focus = true
        } else {
            event.accepted = false
        }
    }

    function edgeEvent(event) {
        indicators.focus = false
        player.forceActiveFocus()
        event.accepted = true
    }

    Keys.onReleased: {
        if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) {
            event.accepted = true
            if (!event.isAutoRepeat && pressCount == 1) {
                if (event.key == Qt.Key_Left) {
                    player.seekBackward()
                } else {
                    player.seekForward()
                }
            } else if (!event.isAutoRepeat) {
                if (wasPlaying) player.play()
                else player.pause()
            } else if ((event.isAutoRepeat && pressCount == 1) || ((pressCount % 30) == 0)) {
                if (event.key == Qt.Key_Left) {
                    player.rewind()
                } else {
                    player.fastForward()
                }
            }
        }
    }

    Controls {
        id: controls
        anchors.left: parent.left; anchors.right: parent.right
        y: controlsVisibility.shown ? parent.height - height : parent.height
        shown: controlsVisibility.shown

        Behavior on y { NumberAnimation {} }

        focus: true

        state: player.state
        video: player.video

        function close() {
            if (player.paused) controlsVisibility.endForceVisible("pause")
            button.focus = true
            focus = false
            player.forceActiveFocus()
        }

        Keys.onEscapePressed: close()

        Keys.forwardTo: [controlsBehavior]

        onButtonClicked: {
            if (["paused", "playing"].indexOf(state) != -1) player.togglePause()
            else player.play()
        }

        onClicked: {
            controlsBehavior.restartTimer()
        }

        onActiveFocusChanged: {
            if (!activeFocus && player.paused) controlsVisibility.endForceVisible("pause")
        }
    }

    TextCustom {
        id: title
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -controls.height / 2

        opacity: player.paused ? 1 : 0

        Behavior on opacity { NumberAnimation {} }

        fontSize: "xxx-large"
        color: "white"

        /*
        effect: DropShadow {
                    blurRadius: 3
                    offset.x: 0
                    offset.y: 1
                    color: "#1e1e1e"
                }
        */

        elide: {
            if (player.nfo.video || video.metaData.title !== undefined) return Text.ElideMiddle
            else return Text.ElideLeft
        }
        text: {
            if (player.nfo.video) return player.nfo.video.title
            else if (video.metaData.title !== undefined) return video.metaData.title
            else return video.source.toString().replace(/.*\//, '')
        }
    }

    VisibilityController {
        id: controlsVisibility
        behavior: controlsBehavior
        onShownChanged: if (!shown && controls.activeFocus) {
            controls.focus = false
            player.forceActiveFocus()
        }

        Connections {
            target: player
            onPausedChanged:
                if (player.paused) controlsVisibility.beginForceVisible("pause")
                else controlsVisibility.endForceVisible("pause")
        }
    }

    TimeoutBehavior {
        id: controlsBehavior
        target: controls
        forcedVisible: controlsVisibility.forceVisible
    }

    Sidebar {
        id: sidebar
        source: "../player/VideoSidebar.qml"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Units.tvPx(550) + borderWidth
        x: sidebarVisibility.shown ? parent.width - width : parent.width

        Behavior on x { NumberAnimation { duration: 125 } }

        Keys.onEscapePressed: {
            focus = false
            player.forceActiveFocus()
        }

        onLoaded: item.video = player.video
    }

    VisibilityController {
        id: sidebarVisibility
        behavior: ImmediateHideBehavior {
            target: sidebar
        }
        onShownChanged: if (!shown && sidebar.activeFocus) {
            sidebar.focus = false
            player.forceActiveFocus()
        }
    }

    onActiveFocusChanged: {
        if (!activeFocus) {
            controls.focus = false
            sidebar.focus = false
            indicators.focus = false
        }
    }
}
