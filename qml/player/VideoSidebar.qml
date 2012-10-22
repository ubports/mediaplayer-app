import QtQuick 2.0
import "../sidebar"
import "../common"
import "../common/units.js" as Units

SidebarView {
    id: videoSidebar
    height: column.height + spacing * 2
    firstItem: languages

    property variant video: null

    Column {
        id: column
        spacing: parent.spacing

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: spacing

        Item {
            height: title.paintedHeight + Units.tvPx(37)
            width: Units.tvPx(470)
            anchors.horizontalCenter: parent.horizontalCenter
            TextCustom {
                id: title
                anchors.bottomMargin: Units.tvPx(22)
                color: "white"
                fontSize: "large"
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignBottom

                elide: Text.ElideRight
                text: {
                    if (player.nfo.video) return player.nfo.video.title
                    else if (video.metaData.title !== undefined) return video.metaData.title
                    else return video.source.toString().replace(/.*\//, '')
                }
            }
        }

        ExpandingDropDown {
            id: languages
            width: Units.tvPx(470)
            anchors.horizontalCenter: parent.horizontalCenter
            container: videoSidebar.container
            spacing: parent.spacing
            first: true

            focus: true

            KeyNavigation.down: subtitles

            label: "Languages"

            model: ListModel {
                ListElement { label: "English" }
                ListElement { label: "Français" }
                ListElement { label: "Polski" }
            }
        }

        ExpandingDropDown {
            id: subtitles
            width: Units.tvPx(470)
            anchors.horizontalCenter: parent.horizontalCenter
            container: videoSidebar.container
            spacing: parent.spacing

            KeyNavigation.up: languages
            KeyNavigation.down: container.visibleArea.heightRatio < 1.0 ? info : subtitles

            label: "Subtitles"

            model: ListModel {
                ListElement { label: "None" }
                ListElement { label: "English" }
                ListElement { label: "Français" }
                ListElement { label: "Polski" }
                ListElement { label: "English" }
                ListElement { label: "Français" }
                ListElement { label: "Polski" }
                ListElement { label: "English" }
                ListElement { label: "Français" }
                ListElement { label: "Polski" }
                ListElement { label: "English" }
                ListElement { label: "Français" }
                ListElement { label: "Polski" }
            }
            selectedIndex: 1
        }

        Rectangle {
            width: Units.tvPx(500)
            height: Units.tvPx(2)
            color: "white"
            opacity: 0.25
        }

        SidebarScrollingComponent {
            id: info
            container: videoSidebar.container
            spacing: parent.spacing
            height: movieInfoHeader.height + movieInfo.height
            width: Units.tvPx(470)
            anchors.horizontalCenter: parent.horizontalCenter
            KeyNavigation.up: subtitles

            TextCustom {
                id: movieInfoHeader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                color: "white"
                fontSize: "small"
                font.weight: Font.DemiBold
                text: "Movie info"
            }

            TextCustom {
                id: movieInfo
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: movieInfoHeader.bottom
                anchors.topMargin: Units.tvPx(30)
                wrapMode: Text.Wrap
                color: "white"
                fontSize: "small"
                property string baseText: '%1<br><br><b>Director:</b> %2<br><br><b>Cast:</b> %3'
                text: (player.nfo.video) ? baseText.arg((player.nfo.video.plot) ? player.nfo.video.plot : "")
                                                .arg((player.nfo.video.director) ? player.nfo.video.director : "")
                                                .arg(player.nfo.getActors().join(", ")) : ""

            }
        }
    }
}
