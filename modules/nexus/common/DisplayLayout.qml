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
    property real scale: 0.12

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

                monitorX: xPos
                monitorY: yPos

                monitorWidth: screenWidth
                monitorHeight: screenHeight
            }
        }
    }

    DragHandler {
        target: canvas
    }
}