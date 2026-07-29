pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

Rectangle {
    id: root

    property string name: ""
    property real scale: 0.12

    property real monitorX: 0
    property real monitorY: 0
    property real monitorWidth: 1920
    property real monitorHeight: 1080

    signal moved(real x, real y)

    x: monitorX * scale
    y: monitorY * scale
    width: monitorWidth * scale
    height: monitorHeight * scale

    radius: 8

    color: "#4F8EF7"
    border.color: "white"
    border.width: 2

    Text {
        anchors.centerIn: parent
        color: "white"
        font.bold: true
        text: root.name
    }

    DragHandler {
        target: root

        onActiveChanged: {
            if (!active) {
                root.moved(
                    root.x / root.scale,
                    root.y / root.scale
                )
            }
        }
    }
}