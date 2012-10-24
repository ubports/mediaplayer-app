import QtQuick 2.0
import QtMultimedia 5.0

Item {
    id: mediaPlayer
    width: 1200; height: 675

    property string formFactor: "tv"
    property string uri: playUri
    property variant volume: playerLoader.item.volume

    Loader {
        id: playerLoader
        source: "player/VideoPlayer.qml"
        anchors.fill: parent
        focus: true
        onLoaded: {
            item.focus = true
            item.playUri(playUri)
        }
    }

    Connections {
        target: playerLoader.item
        onStatusChanged: {
            if (playerLoader.item.status === MediaPlayer.EndOfMedia) {
                application.quit()
            }
        }
    }

    Keys.onReleased: {
        if (!event.isAutoRepeat
            && (event.key == Qt.Key_F11 || event.key == Qt.Key_F)) {
            event.accepted = true
            application.toggleFullscreen();
        }
    }
}
