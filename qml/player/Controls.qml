import QtQuick 1.0
import "../common"
import "../common/utils.js" as Utils
import "../common/units.js" as Units

FocusScope {
    id: controls
    height: mainContainer.height + timelineBackgroundBorderLeft.height

    property bool shown: false
    property variant video: null

    signal buttonClicked

    function removeExt(uri) {
        return uri.toString().substring(0, uri.toString().lastIndexOf("."))
    }

    Item {
        id: mainContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Units.tvPx(160)

        Rectangle {
            id: timelineBackground
            anchors.fill: parent
            color: Utils.darkAubergineDesaturated
            opacity: 0.56

            Rectangle {
                id: timelineBackgroundBorderLeft
                anchors.left: parent.left
                anchors.bottom: parent.top
                color: "white"
                opacity: 0.4
                height: 2
                width: sceneBubble.x + sceneBubble.width / 2 - Units.tvPx(2)
            }

            Rectangle {
                id: timelineBackgroundBorderRight
                anchors.right: parent.right
                anchors.bottom: parent.top
                color: timelineBackgroundBorderLeft.color
                opacity: timelineBackgroundBorderLeft.opacity
                height: timelineBackgroundBorderLeft.height
                width: parent.width - timelineBackgroundBorderLeft.width - timelineBackgroundBorderMiddle.width
            }

            Rectangle {
                id: timelineBackgroundBorderMiddle
                anchors.left: timelineBackgroundBorderLeft.right
                anchors.bottom: parent.top
                color: timelineBackgroundBorderLeft.color
                opacity: timelineBackgroundBorderLeft.opacity * (1 - sceneBubble.opacity)
                height: timelineBackgroundBorderLeft.height
                width: Units.tvPx(6)
            }
        }

        BorderImage {
            id: timeline
            source: "../common/artwork/media_player_bar.sci"

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin: Units.tvPx(48)
            anchors.right: parent.right; anchors.rightMargin: Units.tvPx(268)
            height: 54
        }

        BorderImage {
            id: sceneBubble
            x: sceneSelector.currentItem ? sceneSelector.currentItem.imageX - (width - sceneSelector.itemWidth) / 2 : 0
            height: sceneSelector.currentItem ? Math.ceil(sceneSelector.currentItem.imageHeight + Units.tvPx(51)) : 0
            anchors.bottom: timelineBackground.top
            anchors.bottomMargin: -3
            source: "artwork/bubble.sci"
            smooth: true
            opacity: shown && !sceneSelector.activeFocus ? 1 : 0
            Behavior on opacity { NumberAnimation {} }
        }

        SceneCoverFlow {
            id: sceneSelector
            opacity: shown
            height: Units.tvPx(176)
            anchors.bottom: timelineBackground.top
            anchors.left: parent.left
            anchors.right: parent.right
            stackItems: true
            stackedItemsX: timelineContents.currentPosition - itemWidth / 2
            currentIndex: stackItems ? Math.min(9, Math.floor(video.position / video.duration * 10)) : currentIndex
            property bool hideOnFillerWidthAnimationEnd: false

            KeyNavigation.down: button

            model: ListModel { }

            Behavior on opacity { NumberAnimation {} }

            function open()
            {
                // You would think currentIndexAux and currentIndex would always be the same
                // since they use the same formula, issue is that video.position is updated once set
                // but the signal emitting its change is not set until the video really seeks
                // so here we check that the video has finished seeking before showing the scene selection bar
                var currentIndexAux = Math.min(9, Math.floor(video.position / video.duration * 10))
                if (currentIndex == currentIndexAux) {
                    openTimer.stop()
                    var sceneWidth = itemWidth + spacing
                    var fullScenesThatFitOnScreen = Math.floor(width / sceneWidth)
                    var wantedVisualIndex = Math.max(0, Math.round((stackedItemsX - margin) / sceneWidth))
                    var firstSceneIndexDifference = currentIndex - firstFullSceneIndex - wantedVisualIndex

                    animateContentX = false
                    if (firstFullSceneIndex + firstSceneIndexDifference > count - fullScenesThatFitOnScreen) {
                        firstFullSceneIndex = count - fullScenesThatFitOnScreen
                    } else {
                        firstFullSceneIndex += firstSceneIndexDifference
                    }
                    animateContentX = true

                    if (controlsVisibility) {
                        controlsVisibility.beginForceVisible("sceneSelector")
                    }
                    stackItems = false
                }
            }

            Timer {
                id: openTimer
                interval: 50
                repeat: true
                onTriggered: sceneSelector.open()
            }

            onActiveFocusChanged: {
                if (activeFocus) {
                    var realCurrentIndex = Math.min(9, Math.round(video.position / video.duration * 10))
                    if (currentIndex != realCurrentIndex) {
                        openTimer.start()
                    } else {
                        open();
                    }
                } else {
                    stackItems = true
                    if (controlsVisibility) {
                        controlsVisibility.endForceVisible("sceneSelector")
                    }
                }
            }

            onItemClicked: {
                hideOnFillerWidthAnimationEnd = true
                video.position = Math.ceil(video.duration * sceneSelector.currentIndex / 10)
            }

            Keys.priority: Keys.AfterItem

            Keys.onPressed: {
                if (event.key == Qt.Key_Down && hideOnFillerWidthAnimationEnd) {
                    // We will hide in a sec, ignore eat the event
                    event.accepted = true
                }
                if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) {
                    event.accepted = true
                }
            }

            Keys.onReleased: {
                if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) {
                    event.accepted = true
                }
            }

            Keys.onEscapePressed: {
                button.focus = true
            }
        }

        Connections {
            target: positionFillerWidthAnimation
            onRunningChanged: {
                if (sceneSelector.hideOnFillerWidthAnimationEnd && !positionFillerWidthAnimation.running) {
                    sceneSelector.hideOnFillerWidthAnimationEnd = false
                    button.focus = true
                }
            }
        }

        Connections {
            target: video
            onDurationChanged: {
                sceneSelector.previousCurrentIndex = -1
                sceneSelector.firstFullSceneIndex = 0
                sceneSelector.model.clear()
                for (var i = 0; i < 10; ++i) {
                    sceneSelector.model.append({"imageSource": removeExt(video.source) + "_" + i + (".tmb")})
                }
            }
        }

        Item {
            id: timelineContents
            property int currentPosition: x + positionFiller.x + positionFiller.width

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: timeline.left; anchors.leftMargin: Units.tvPx(13)
            anchors.right: timeline.right; anchors.rightMargin: Units.tvPx(13)
            height: 28

            Item {
                id: bufferFiller
                anchors.top: parent.top; anchors.bottom: parent.bottom
                anchors.left: parent.left
                // FIXME make the buffer bar reflect buffer fill
                width: 0
                clip: true

                Behavior on width { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }

                BorderImage {
                        id: bufferFillerImage
                        source: "artwork/timeline_loaded.sci"

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: timelineContents.width
                }
            }

            Item {
                id: positionFiller
                width: timelineContents.width * (video.position / video.duration)
                anchors.top: parent.top; anchors.bottom: parent.bottom
                anchors.left: parent.left
                clip: true

                Behavior on width { NumberAnimation { id: positionFillerWidthAnimation; duration: 75; easing.type: Easing.OutQuad } }

                BorderImage {
                        id: positionFillerImage
                        source: "artwork/timeline_watched.sci"

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: timelineContents.width
                }
            }

            Item {
                id: sceneMarker
                width: video.duration != 0 ? timelineContents.width * (Math.min(video.duration / 10, video.duration - sceneSelector.currentIndex  * video.duration / 10) / video.duration) : width
                anchors.top: parent.top; anchors.bottom: parent.bottom
                x: timelineContents.width * (sceneSelector.currentIndex / 10)
                opacity: sceneSelector.activeFocus ? 1 : 0
                clip: true

                Behavior on x { NumberAnimation { } }
                Behavior on width { NumberAnimation { } }
                Behavior on opacity { NumberAnimation { } }

                BorderImage {
                    id: sceneMarkerImage
                    source: "artwork/scene_position_rounded.sci"

                    x: -border.left + Math.max(border.left - sceneMarker.x, 0) - Math.max(sceneMarker.x + sceneMarker.width + border.right - timelineContents.width, 0)
                    width: sceneMarker.width + border.left + border.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
            }

            AbstractButton {
                id: button
                anchors.horizontalCenter: positionFiller.right
                anchors.verticalCenter: parent.verticalCenter
                width: Units.tvPx(106); height: width
                focus: true
                KeyNavigation.up: sceneSelector

                state: activeFocus ? "selected" : "default"

                property string iconPath: "artwork/icon_%1.png"
                property string selectedIconPath: "artwork/icon_%1_orange.png"
                property string icon
                property string iconSource
                property bool switchIcons: false

                iconSource: {
                    if (icon) {
                        if (state == "selected") {
                            return selectedIconPath.arg(icon)
                        } else {
                            return iconPath.arg(icon)
                        }
                    } else return ""
                }

                Rectangle {
                    id: buttonBackground
                    anchors.fill: parent
                    color: "#482d2a"
                    radius: Units.tvPx(18)

                    border.color: "#ffffff"
                    border.width: width * 0.04
                }

                Image {
                    id: iconOne
                    anchors.centerIn: parent
                    width: Units.tvPx(sourceSize.width)
                    height: Units.tvPx(sourceSize.height)
                    smooth: true
                    opacity: button.switchIcons ? 0 : 1

                    Behavior on opacity { NumberAnimation { duration: 125 } }
                }

                Image {
                    id: iconTwo
                    anchors.centerIn: parent
                    width: Units.tvPx(sourceSize.width)
                    height: Units.tvPx(sourceSize.height)
                    smooth: true
                    opacity: button.switchIcons ? 1 : 0

                    Behavior on opacity { NumberAnimation { duration: 125 } }
                }

                Image {
                    id: buttonGlow
                    source: "artwork/play_glow.png"
                    anchors.centerIn: parent
                    width: Units.tvPx(sourceSize.width)
                    height: Units.tvPx(sourceSize.height)
                    smooth: true

                    opacity: button.state == "selected" ? 1 : 0

                    Behavior on opacity { NumberAnimation {} }
                }

                onIconSourceChanged: {
                    if (!switchIcons) { iconTwo.source = iconSource }
                    else { iconOne.source = iconSource }
                    switchIcons = !switchIcons
                }

                onClicked: buttonClicked()
            }
        }

        Item {
            anchors.left: timeline.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            TextCustom {
                id: positionText
                anchors.centerIn: parent

                font.family: "Ubuntu"
                fontSize: "x-large"
                color: "white"
                style: Text.Outline
                styleColor: "grey"

                text: Utils.format_time(video.duration - video.position, Utils.get_human_time_format(video.duration))
            }
        }
    }

    states: [
        State {
            name: "stopped"
            PropertyChanges { target: button; icon: "stop" }
        },

        State {
            name: "playing"
            PropertyChanges { target: button; icon: "play" }
        },

        State {
            name: "paused"
            PropertyChanges { target: button; icon: "pause" }
        },

        State {
            name: "forwarding"
            PropertyChanges { target: button; icon: "forward" }
        },

        State {
            name: "rewinding"
            PropertyChanges { target: button; icon: "rewind" }
        }
    ]
}
