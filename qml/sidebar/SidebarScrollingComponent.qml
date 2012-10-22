import QtQuick 2.0
import "../common"

SidebarComponent {
    Binding {
        target: container
        property: "scrollbarFocused"
        value: activeFocus
        when: activeFocus
    }

    Keys.onReturnPressed: {}

    Keys.onUpPressed: {
        if (!event.isAutoRepeat) {
            var top = first ? 0 : y
            if (container.contentY > top) {
                container.contentY = Math.max(container.contentY - 200, top)
            } else {
                event.accepted = false
            }
        }
    }

    Keys.onDownPressed: {
        if (!event.isAutoRepeat) {
            var bottom = y + height + spacing * 2
            var containerBottom = container.contentY + container.height

            if (containerBottom < bottom) {
                container.contentY = Math.min(container.contentY + 200, bottom - container.height)
            } else {
                event.accepted = false
            }
        }
    }
}
