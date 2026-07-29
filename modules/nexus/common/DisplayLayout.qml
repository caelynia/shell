pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

Rectangle {
    id: root

    property var display_model
    property real minimumScale: 0.05
    property real maximumScale: 0.4
    property real zoomFactor: 1.1

    property real panX: 40
    property real panY: 40

    property real displayPanX: panX
    property real displayPanY: panY

    readonly property int displayWidth: 700
    readonly property int displayHeight: 350

    property real effectiveScale: 0.12
    property real displayScale: effectiveScale

    property real zoomAccumulator: clampScale(1.0)

    Behavior on displayPanX {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Behavior on displayPanY {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Behavior on displayScale {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutBack
            easing.overshoot: 1.15
        }
    }

    function clampScale(val) {
        return Math.max(root.minimumScale, Math.min(root.maximumScale, val))
    }

    color: Colours.tPalette.m3surfaceContainer
    radius: 10
    clip: true

    implicitHeight: displayHeight
    implicitWidth: displayWidth

    Item {
        id: canvas

        x: root.displayPanX
        y: root.displayPanY
        scale: root.displayScale

        Repeater {
            id: repeater

            model: root.display_model

            delegate: DisplayMonitor {
                required property string name
                required property int xPos
                required property int yPos
                required property int screenWidth
                required property int screenHeight

                monitorName: name

                monitorX: xPos
                monitorY: yPos

                monitorWidth: screenWidth
                monitorHeight: screenHeight
            }
        }
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: event => {
            const oldScale = root.effectiveScale;
            const factor = event.angleDelta.y > 0 ? root.zoomFactor : 1 / root.zoomFactor;
            const newScale = root.clampScale(oldScale * factor);

            if (newScale === oldScale) {
                return;
            }

            const ratio = newScale / oldScale;

            root.panX = event.x - (event.x - root.panX) * ratio;
            root.panY = event.y - (event.y - root.panY) * ratio;

            root.displayPanX = root.panX;
            root.displayPanY = root.panY;
            root.effectiveScale = newScale;
            root.displayScale = newScale;
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.MiddleButton

        property real lastX: 0
        property real lastY: 0

        onPressed: event => {
            lastX = event.x
            lastY = event.y
        }

        onPositionChanged: event => {
            if (pressed) {
                root.panX += event.x - lastX
                root.panY += event.y - lastY

                root.displayPanX = root.panX
                root.displayPanY = root.panY

                lastX = event.x
                lastY = event.y
            }
        }

        onWheel: event => { event.accepted = false }
    }
}