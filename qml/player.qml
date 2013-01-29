import QtQuick 2.0
import QtMultimedia 5.0
import QtSensors 5.0

Rectangle {
    id: mediaPlayer
    width: screenWidth
    height: screenHeight

    property string orientation: portrait ? (screenHeight <= screenWidth ? "270" : "0") : ""
    property string formFactor: "tv"
    property real volume: playerLoader.item.volume

    Loader {
        id: playerLoader
        source: "player/VideoPlayer.qml"
        focus: true
        anchors.fill: parent
        clip: true
        onLoaded: {
            item.focus = true
            item.playUri(playUri)
            item.rotating = Qt.binding(function () { return rotatingTransition.running } )
        }

        state: mediaPlayer.orientation != "" ? mediaPlayer.orientation : (screenHeight <= screenWidth ? "0" : "270")

        Component.onCompleted: {
            state = Qt.binding(function () {
                return mediaPlayer.orientation != "" ? mediaPlayer.orientation : (screenHeight <= screenWidth ? "0" : "270")
            })
        }

        states:  [
          State {
            name: "0"
            PropertyChanges {
              target: mediaPlayer
              rotation: 0
              width: screenWidth
              height: screenHeight
              x: 0
              y: 0
            }
          },
          State {
            name: "180"
            PropertyChanges {
              target: mediaPlayer
              rotation: 180
              width: screenWidth
              height: screenHeight
              x: 0
              y: 0
            }
          },
          State {
            name: "270"
            PropertyChanges {
              target: mediaPlayer
              rotation: 270
              width: screenHeight
              height: screenWidth
              x: (screenWidth - screenHeight) / 2
              y: -(screenWidth - screenHeight) / 2
            }
          },
          State {
            name: "90"
            PropertyChanges {
              target: mediaPlayer
              rotation: 90
              width: screenHeight
              height: screenWidth
              x: (screenWidth - screenHeight) / 2
              y: -(screenWidth - screenHeight) / 2
            }
          }
        ]

        transitions: [
          Transition {
            id: rotatingTransition
            ParallelAnimation {
              RotationAnimation {
                properties: "rotation"
                duration: 250
                direction: RotationAnimation.Shortest
              }
              PropertyAnimation {
                target: mediaPlayer
                properties: "x,y,width,height"
                duration: 250
              }
            }
          }
        ]

        OrientationSensor {
            id: orientationSensor
            active: true

            // Causes the media player UI to rotate when the target device is rotated
            onReadingChanged: {
                if (reading.orientation == OrientationReading.LeftUp) {
                    mediaPlayer.orientation = "270"
                }
                else if (reading.orientation == OrientationReading.RightUp) {
                    mediaPlayer.orientation = "90"
                }
                else if (reading.orientation == OrientationReading.TopUp) {
                    mediaPlayer.orientation = "0"
                }
                else if (reading.orientation == OrientationReading.TopDown) {
                    mediaPlayer.orientation = "180"
                }
            }
        }
    }

    Connections {
        target: playerLoader.item
        onStatusChanged: {
            if (playerLoader.item.status === MediaPlayer.EndOfMedia) {
                Qt.quit()
            }
        }
    }

    function rotateClockwise() {
        if (orientation == "") orientation = playerLoader.state
        if (orientation == "0") orientation = "270"
        else if (orientation == "270") orientation = "180"
        else if (orientation == "180") orientation = "90"
        else orientation = "0"
    }

    function rotateCounterClockwise() {
        if (orientation == "") orientation = playerLoader.state
        if (orientation == "0") orientation = "90"
        else if (orientation == "90") orientation = "180"
        else if (orientation == "180") orientation = "270"
        else orientation = "0"
    }

    Keys.onReleased: {
        if (!event.isAutoRepeat
            && (event.key == Qt.Key_F11 || event.key == Qt.Key_F)) {
            event.accepted = true
            application.toggleFullscreen();
        } else if (!event.isAutoRepeat && event.key == Qt.Key_BracketLeft) {
            event.accepted = true
            rotateClockwise()
        } else if (!event.isAutoRepeat && event.key == Qt.Key_BracketRight) {
            event.accepted = true
            rotateCounterClockwise()
        }
    }
}
