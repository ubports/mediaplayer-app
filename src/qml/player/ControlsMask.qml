import QtQuick 2.0
import QtGraphicalEffects 1.0


Item {
    id: _controlsMask

    property variant controls
    property variant videoOutput

    LinearGradient {
        id: _mask

        anchors.fill: parent
        start: Qt.point(0, controls.y)
        end: Qt.point(0, controls.y + controls.height)
        visible: false

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00ffffff" }
            GradientStop { position: 0.1; color: "#000000" }
        }
    }

    MaskedBlur {
        anchors.fill: parent
        source: videoOutput
        maskSource: _mask
        radius: 99
        samples: 39
        fast: true
    }
}
