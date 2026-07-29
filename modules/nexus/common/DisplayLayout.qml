import QtQuick

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

    color: "#232323"
    radius: 10
    clip: true

    implicitHeight: 350
    implicitWidth: 700

    Item {
        id: canvas

        x: 40
        y: 40

        Repeater {
            model: root.display_model

            delegate: DisplayMonitor {
                scale: root.scale

                name: display_model.name

                monitorX: display_model.xPos
                monitorY: display_model.yPos

                monitorWidth: display_model.width
                monitorHeight: display_model.height

                onMoved: {
                    root.display_model.setProperty(index, "xPos", x)
                    root.display_model.setProperty(index, "yPos", y)
                }
            }
        }
    }

    DragHandler {
        target: canvas
    }
}