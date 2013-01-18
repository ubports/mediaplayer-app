/*
 * This file is part of unity-2d
 *
 * Copyright 2010-2011 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../common"
import "../common/units.js" as Units
import "../common/utils.js" as Utils

ListView {
    id: flow

    property int previousCurrentIndex: -1
    property int firstFullSceneIndex: 0
    property bool stackItems: false
    property alias animateContentX: contentXAnimation.enabled
    property real stackedItemsX: 0

    property real margin: Units.tvPx(135)
    property real itemWidth: Units.tvPx(245)
    signal itemClicked
    signal seekRequested

    cacheBuffer: width / 2
    orientation: ListView.Horizontal
    spacing: Units.tvPx(36)
    contentX: firstFullSceneIndex * (itemWidth + spacing)
    Behavior on contentX { id: contentXAnimation; enabled: true; SmoothedAnimation {duration: 300}}

    function previous() {
        if (currentIndex > 0) currentIndex -= 1
        seekRequested()
    }

    function next() {
        if (currentIndex < count + 1) currentIndex += 1
        seekRequested()
    }

    // TODO See if we can make it work with highlightRangeMode & friends
    onCurrentIndexChanged:
    {
        if (!stackItems) {
            if (previousCurrentIndex != -1) {
                if (previousCurrentIndex < currentIndex) {
                    // Going to the right
                    var fullScenesThatFitOnScreen = Math.floor(width / (itemWidth + spacing))
                    if (currentIndex - firstFullSceneIndex >= fullScenesThatFitOnScreen - 1) {
                        // We went to the one before the end
                        if (currentIndex < count - 1) { 
                            // But not that much too the end
                            firstFullSceneIndex++
                        } else {
                            firstFullSceneIndex = count - fullScenesThatFitOnScreen
                        }
                    }
                } else if (previousCurrentIndex > currentIndex) {
                    // Going to the left
                    if (currentIndex <= firstFullSceneIndex) {
                        if (currentIndex != 0) {
                            // But not that much too the beginning
                            firstFullSceneIndex--
                        } else {
                            firstFullSceneIndex = 0
                        }
                    }
                }
            }
            previousCurrentIndex = currentIndex
        }
    }

    delegate: Item {
        id: item

        property variant imageSourceUrl: imageSource
        property alias imageHeight: image.height
        property alias imageX: looseItem.x

        property variant segments: [-flow.itemWidth, 0.0, flow.width - flow.itemWidth - margin * 2, flow.width - margin * 2]
        property real absoluteX: item.x - flow.contentX

        width: delegateButton.width
        height: delegateButton.height

        Keys.forwardTo: [delegateButton]

        Item {
            id: looseItem
            parent: flow
            x: margin + item.x - flow.contentX
            y: item.y - flow.contentY
            width: item.width
            height: item.height
            z: flow.z + flow.count - Math.abs(index - flow.currentIndex)
            property real unstackingFactor: 1

            states: [
                State {
                    name: "stacked"
                    when: stackItems
                    PropertyChanges {
                        target: looseItem
                        x: stackedItemsX
                        unstackingFactor: 0
                        visible: index == currentIndex
                    }
                },
                State {
                    name: "unstacked"
                    when: !stackItems
                    PropertyChanges {
                        target: looseItem
                        visible: true
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "stacked"
                    to: "unstacked"
                    reversible: true
                    PropertyAnimation {
                        properties: "x, unstackingFactor"
                        easing.type: Easing.OutQuad
                    }
                }
            ]

            AbstractButton {
                id: delegateButton

                width: flow.itemWidth
                height: flow.height

                property real angle: Utils.segmentsLinearInterpolation(segments, [63.0, 0.0, 0.0, -63.0], absoluteX)
                property real origin: Utils.segmentsLinearInterpolation(segments, [width, width, 0.0, 0.0], absoluteX)
                transform: Rotation { origin.x: delegateButton.origin; origin.y: height/2; axis { x: 0; y: 1; z: 0 } angle: looseItem.unstackingFactor * delegateButton.angle}
                property real scaleHelper: 1 - 0.2 * looseItem.unstackingFactor // 0.8 + (1 - 0.8) * (1 - looseItem.unstackingFactor)
                scale: Utils.segmentsLinearInterpolation(segments, [scaleHelper, 1.0, 1.0, scaleHelper], absoluteX)

                onClicked: {
                    flow.currentIndex = index
                    flow.itemClicked()
                }

                Item {
                    width: image.width
                    height: image.height
                    anchors.centerIn: image

                    Image {
                        source: "artwork/scene_selection_glow.png"
                        anchors.fill: parent
                        anchors.margins: Units.tvPx(-27)
                        opacity: item.activeFocus && looseItem.state == "unstacked" ? 1.0 : 0.0
                        smooth: true
                        Behavior on opacity {NumberAnimation {duration: 200; easing.type: Easing.OutQuad}}
                    }

                    Rectangle {
                        id: outline
                        anchors.centerIn: parent
                        width: parent.width + Units.tvPx(3) * 2
                        height: parent.height + Units.tvPx(3) * 2
                        color: "black"
                        smooth: true
                        radius: Units.tvPx(2)
                    }
                }


                Image {
                    id: image

                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    clip: true
                    width: Units.tvPx(245)
                    height: Units.tvPx(130)

                    source: imageSourceUrl
                    smooth: true
                    asynchronous: true

                    opacity: 0

                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    onSourceChanged: opacity = 0
                    onStatusChanged: if (status == Image.Ready) opacity = 1
                }
            }
        }
    }
}
