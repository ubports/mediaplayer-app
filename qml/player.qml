import QtQuick 2.0
import QtMultimedia 5.0

Rectangle {
    id: mediaPlayer
    width: screenWidth
    height: screenHeight

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
        }

        state: orientation

        states:  [
          State {
            name: "Landscape"
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
            name: "LandscapeInverted"
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
            name: "Portrait"
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
            name: "PortraitInverted"
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
    }

    Connections {
        target: playerLoader.item
        onStatusChanged: {
            if (playerLoader.item.status === MediaPlayer.EndOfMedia) {
                application.quit()
            }
        }
        onTimeClicked: {
            rotateClockwise()
        }
    }

    function rotateClockwise() {
        if (playerLoader.state == "Landscape") playerLoader.state = "Portrait"
        else if (playerLoader.state == "Portrait") playerLoader.state = "LandscapeInverted"
        else if (playerLoader.state == "LandscapeInverted") playerLoader.state = "PortraitInverted"
        else playerLoader.state = "Landscape"
    }

    function rotateCounterClockwise() {
        if (playerLoader.state == "Landscape") playerLoader.state = "PortraitInverted"
        else if (playerLoader.state == "PortraitInverted") playerLoader.state = "LandscapeInverted"
        else if (playerLoader.state == "LandscapeInverted") playerLoader.state = "Portrait"
        else playerLoader.state = "Landscape"
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
