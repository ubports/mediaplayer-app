/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Ubuntu.Components.ListItems 0.1 as ListItem

Item {
    id: sharemenu
    property string picturePath
    signal selected()

    height: childrenRect.height

    ListView {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        interactive: false
        model: ListModel {
            ListElement { service: "Facebook"; user: "lolachang2010@yahoo.co.uk"; iconPath: "image://gicon/facebook" }
            ListElement { service: "Twitter"; user: "@lola_chang"; iconPath: "image://gicon/twitter" }
            ListElement { service: "Ubuntu One"; user: "lolachang"; iconPath: "image://gicon/ubuntuone" }
            ListElement { service: "Gmail"; user: "lolachang2010@gmail.com"; iconPath: "image://gicon/gmail" }
            ListElement { service: "Pinterest"; user: "lolachang2010@yahoo.co.uk"; iconPath: "image://gicon/pinterest" }
        }

        delegate: ListItem.Subtitled {
            text: service
            subText: user
            icon: Qt.resolvedUrl(iconPath)
            __iconHeight: units.gu(5)
            __iconWidth: units.gu(5)

            onClicked: {
                sharemenu.selected()
                if (service == "Facebook") {
                    if (loader.status != Loader.Ready) console.log("Application launching not available on this platform");
                    else loader.item.switchToShareApplication();
                } else {
                    console.log("Sharing to this service is not supported yet.")
                }
            }
        }
    }

    Loader {
        id: loader
        source: "UbuntuApplicationWrapper.qml"
    }
}
