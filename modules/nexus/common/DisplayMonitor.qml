pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

Rectangle {
    id: root

    property string monitorName: ""
    property real monitorScale: 0.12

    property real monitorX: 0
    property real monitorY: 0
    property real monitorWidth: 1920
    property real monitorHeight: 1080

    signal moved(real x, real y)

    x: monitorX * monitorScale
    y: monitorY * monitorScale
    width: monitorWidth * monitorScale
    height: monitorHeight * monitorScale

    radius: 8

    color: Colours.tPalette.m3primary
    border.color: "white"
    border.width: 2

    Text {
        anchors.centerIn: parent
        color: "white"
        font.bold: true
        text: monitorName
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