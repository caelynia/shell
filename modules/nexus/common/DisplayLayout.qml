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
    property real scale: 0.1
    property real minimumScale: 0.05
    property real maximumScale: 0.4
    property real zoomFactor: 1.1
    property real dragOffsetX: 0
    property real dragOffsetY: 0
    property real lastX: 0
    property real lastY: 0

    color: Colours.tPalette.m3surfaceContainer
    radius: 10
    clip: true

    implicitHeight: 350
    implicitWidth: 700

    Item {
        id: canvas

        x: 40
        y: 40

        Repeater {
            id: repeater

            model: root.display_model

            delegate: DisplayMonitor {
                required property string name
                required property int xPos
                required property int yPos
                required property int screenWidth
                required property int screenHeight

                monitorScale: root.scale
                monitorName: name

                monitorX: xPos + dragOffsetX
                monitorY: yPos + dragOffsetY

                monitorWidth: screenWidth
                monitorHeight: screenHeight
            }
        }
    }

    WheelHandler {
        id: zoomHandler

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: event => {
            if (event.angleDelta.y > 0)
                root.scale *= root.zoomFactor
            else
                root.scale /= root.zoomFactor
            root.scale = Math.max(root.minimumScale, Math.min(root.maximumScale, root.scale))
        }
    }

    MouseArea {
        id: _panArea
        anchors.fill: parent
        drag.target: canvas
        propagateComposedEvents: false
        acceptedButtons: Qt.LeftButton
        onPositionChanged: (event) => {
            root.dragOffsetX += Number(event.x) - Number(event.previousX)
            root.dragOffsetY += Number(event.y) - Number(event.previousY)
        }
    }
}