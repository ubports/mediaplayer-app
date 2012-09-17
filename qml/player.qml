import QtQuick 1.1

Item {
    id: mediaPlayer
    width: 800; height: 450

    property string formFactor: "tv"
    property string uri: "file:///home/michal/Wideo/Test/20100725_001.mp4"
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
