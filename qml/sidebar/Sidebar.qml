import QtQuick 1.0
import "../common"
import "../common/utils.js" as Utils
import "../common/units.js" as Units

FocusScope {
    id: sidebar
    Accessible.name: "sidebar"

    property alias source: loader.source
    property alias status: loader.status
    property alias item: loader.item
    property alias borderWidth: backgroundBorderLeft.width

    signal loaded

    Rectangle {
        id: background
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width - backgroundBorderLeft.width
        color: Utils.darkAubergineDesaturated
        opacity: 0.56

        Rectangle {
            id: backgroundBorderLeft
            width: Units.tvPx(2)
            height: parent.height
            anchors.top: parent.top
            anchors.right: parent.left
            color: "white"
            opacity: 0.4
        }
    }

    Keys.onPressed: { if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) event.accepted = true }
    Keys.onReleased: { if (event.key == Qt.Key_Left || event.key == Qt.Key_Right) event.accepted = true }

    Item {
        id: content

        anchors.fill: parent

        Flickable {
            id: flickable
            clip: true

            property bool scrollbarFocused: false

            anchors.top: parent.top
            anchors.topMargin: Units.tvPx(40)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.tvPx(40)
            anchors.left: parent.left
            anchors.leftMargin: Units.tvPx(24)
            anchors.right: scrollbar.left
            anchors.rightMargin: Units.tvPx(10)
            interactive: false

            contentHeight: loader.item.height

            Behavior on contentX { NumberAnimation { } }
            Behavior on contentY { NumberAnimation { } }

            Loader {
                id: loader
                Accessible.name: "loader"

                anchors.top: parent.top
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 6; anchors.rightMargin: 6

                focus: true
                onLoaded: {
                    item.focus = true
                    item.container = flickable
                    sidebar.loaded()
                }
            }

            Binding {
                target: loader.item
                when: loader.status == Loader.Ready
                property: "container"
                value: flickable
            }
        }

        AbstractScrollbar {
            id: scrollbar

            width: 5

            anchors.top: parent.top
            anchors.topMargin: Units.tvPx(15)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.tvPx(15)
            anchors.right: parent.right
            anchors.rightMargin: Units.tvPx(10)

            targetFlickable: flickable
            /* The glow around the slider is 10 pixels wide. */
            sliderAnchors.rightMargin: -10
            sliderAnchors.leftMargin: -10
            sliderAnchors.topMargin: -10
            sliderAnchors.bottomMargin: -10

            sliderSmooth: false

            sliderSource: "artwork/scroll_bar.sci"

            /* Hide the scrollbar if there is less than a page of results */
            opacity: (targetFlickable.visibleArea.heightRatio < 1.0) && !flickable.scrollbarFocused ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { } }
        }

        AbstractScrollbar {
            id: glowingScrollbar

            width: 5

            anchors.fill: scrollbar

            targetFlickable: flickable
            sliderAnchors.rightMargin: -10
            sliderAnchors.leftMargin: -10
            sliderAnchors.topMargin: -10
            sliderAnchors.bottomMargin: -10

            sliderSmooth: false

            sliderSource: "artwork/scroll_glow.sci"

            opacity: (targetFlickable.visibleArea.heightRatio < 1.0) && flickable.scrollbarFocused ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { } }
        }
    }
}
