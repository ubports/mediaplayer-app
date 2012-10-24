import QtQuick 2.0
import "../common"
import "../common/units.js" as Units

SidebarComponent {
    id: expandingDropDown

    property alias label: label.text
    property alias itemHeight: dropDown.itemHeight
    property alias maxHeight: dropDown.maxHeight
    property alias maxItems: dropDown.maxItems
    property alias minItems: dropDown.minItems
    property alias contextItems: dropDown.contextItems
    property alias model: dropDown.model
    property alias delegate: dropDown.delegate
    property alias selectedIndex: dropDown.selectedIndex
    property alias selectedItem: dropDown.selectedItem

    height: label.height + dropDown.height + spacing * 2

    TextCustom {
        id: label
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: spacing
        height: paintedHeight
        color: "white"
        fontSize: "small"
        font.weight: Font.DemiBold
        verticalAlignment: Text.AlignBottom
    }

    AbstractExpandingDropDown {
        id: dropDown
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: label.bottom; anchors.topMargin: spacing

        focus: true

        maxHeight: container ? container.height + container.contentY - containerYOffset - parent.y - y - spacing * 2 : undefined
        maxItems: 10
        minItems: 3
        contextItems: 2
        itemHeight: Units.tvPx(63)

        Keys.onReturnPressed: {
            toggle()
        }

        Keys.onEscapePressed: {
            if (state == "expanded") dismiss()
            else event.accepted = false
        }

        onAnimatingChanged: {
            if (!animating && activeFocus) {
                var bottom = containerYOffset + parent.height
                var containerBottom = container.contentY + container.height
                if (containerBottom < bottom) {
                    container.contentY = bottom - container.height + spacing * 2
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: dropDown.state == "collapsed"
            onClicked: { dropDown.forceActiveFocus(); dropDown.open() }
        }

        delegate:
            Item {
                anchors.left: parent.left; anchors.right: parent.right
                height: itemHeight
                TextCustom {
                    text: label
                    anchors.fill: parent
                    color: "white"
                    fontSize: "small"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: dropDown.state == "expanded"
                    onClicked: { dropDown.selectedIndex = index; dropDown.state = "collapsed" }
                }
            }

        // dummy highlight
        highlight: Item {}
    }

    Item {
        anchors.fill: dropDown
        anchors.margins: Units.tvPx(-19)
        anchors.topMargin: Units.tvPx(-18)
        anchors.rightMargin: Units.tvPx(-20)
        clip: true

        // actual highlight
        Item {
            x: 18 + dropDown.listView.highlightItem.x - dropDown.listView.contentX
            y: 19 + dropDown.listView.highlightItem.y - dropDown.listView.contentY
            width: dropDown.listView.highlightItem.width
            height: dropDown.listView.highlightItem.height
            opacity: dropDown.activeFocus ? 0.8 : 0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            BorderImage {
                anchors.fill: parent
                anchors.margins: Units.tvPx(-19)
                anchors.topMargin: Units.tvPx(-18)
                anchors.rightMargin: Units.tvPx(-20)
                source: "../common/artwork/button_glow.sci"
            }
        }
    }

    Image {
        id: topArrow
        source: "../common/artwork/arrow.png"
        anchors.bottom: dropDown.top
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: !dropDown.topVisible && dropDown.state == "expanded" && parent.activeFocus ? 1 : 0
        rotation: -90
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    Image {
        id: bottomArrow
        source: "../common/artwork/arrow.png"
        anchors.top: dropDown.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: !dropDown.bottomVisible && dropDown.state == "expanded" && parent.activeFocus ? 1 : 0
        rotation: 90
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    Rectangle {
        id: background
        anchors.fill: dropDown
        color: "white"
        opacity: parent.activeFocus ? 0.05 : 0.2
        radius: Units.tvPx(16)

        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    Rectangle {
        id: border
        anchors.fill: dropDown
        color: "transparent"
        opacity: parent.activeFocus ? 0.1 : 0.5
        radius: Units.tvPx(16)

        border.color: "white"
        border.width: 3

        Behavior on opacity { NumberAnimation { duration: 250 } }
    }
}
