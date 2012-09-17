import QtQuick 1.0
import "../common/units.js" as Units

FocusScope {
    property variant container
    property variant firstItem
    property int spacing: Units.tvPx(33)

    Behavior on height { NumberAnimation {} }

    onActiveFocusChanged: { if (!activeFocus && firstItem) { firstItem.focus = true } }
}
