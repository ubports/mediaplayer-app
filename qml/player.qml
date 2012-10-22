import QtQuick 2.0

Item {
    id: mediaPlayer
    width: 1200; height: 675

    property string formFactor: "tv"
    property string uri: "file:///home/michal/Wideo/Filmy/Oslo.31.August.2011.720p.BluRay.x264-CiNEFiLE/Oslo.31.August.2011.720p.BluRay.x264-CiNEFiLE.mkv"
    property variant volume: playerLoader.item.volume

    function play() {
        if (mediaPlayer.uri) {
            console.log("playing uri: " + mediaPlayer.uri)
            playerLoader.item.playUri(mediaPlayer.uri)
        } else {
            console.log("Error: no uri specified")
        }
    }

    Loader {
        id: playerLoader
        source: "player/VideoPlayer.qml"
        anchors.fill: parent
        focus: true
        onLoaded: {
            item.focus = true
            mediaPlayer.play()
        }
    }
}
