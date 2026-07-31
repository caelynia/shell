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
    property int monitorID: 0
    property real monitorX: 0
    property real monitorY: 0
    property real monitorWidth: 1920
    property real monitorHeight: 1080
    property real monitorScale: 1

    signal moved(real x, real y)

    x: monitorX
    y: monitorY
    width: monitorWidth / monitorScale
    height: monitorHeight / monitorScale

    radius: 40
    color: Colours.tPalette.m3surfaceContainer
    border.color: Colours.tPalette.m3primary
    border.width: 20

    Text {
        anchors.centerIn: parent
        color: Colours.tPalette.m3primary
        font.pixelSize: 150
        font.bold: true
        text: monitorName
    }

    DragHandler {
        target: root

        onActiveChanged: {
            if (!active) {
                root.moved(
                    root.monitorX / root.monitorScale,
                    root.monitorY / root.monitorScale
                )
            }
        }
    }
}