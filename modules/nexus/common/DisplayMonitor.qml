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
    property int monitorX: 0
    property int monitorY: 0
    property int monitorWidth: 1920
    property int monitorHeight: 1080
    property real monitorScale: 1

    property real u: 0;
    property real v: 0;
    property var monitorSnapTargets: []

    readonly property int snapDistance: 200

    signal moved(int id, int x, int y, int w, int h)
    signal pressed(int monitorID)

    x: monitorX
    y: monitorY
    width: monitorWidth / monitorScale
    height: monitorHeight / monitorScale

    radius: 40
    color: Colours.tPalette.m3surfaceContainer
    border.color: Colours.tPalette.m3primary
    border.width: 20

    Column {
        anchors.centerIn: parent
        spacing: 15

        Text {
            text: monitorName
            color: Colours.tPalette.m3primary
            font.pixelSize: 200
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: `${Math.round(monitorWidth)} × ${Math.round(monitorHeight)}`
            color: Colours.tPalette.m3primary
            font.pixelSize: 150
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    TapHandler {
        onPressedChanged: {
            if (pressed) {
                root.u = point.position.x / root.width;
                root.v = point.position.y / root.height;

                root.pressed(root.monitorID)
            }
        }
    }

    DragHandler {
        id: drag

        target: null

        onActiveTranslationChanged: {
            const mouseX = root.x + centroid.position.x;
            const mouseY = root.y + centroid.position.y;

            let targetX = mouseX - u * root.width;
            let targetY = mouseY - v * root.height;

            let snapDistanceX = root.snapDistance;
            let snapDistanceY = root.snapDistance;

            let snapX = targetX;
            let snapY = targetY;

            let minSnapX = root.snapDistance;
            let minSnapY = root.snapDistance;

            const currentMinX = targetX;
            const currentMinY = targetY;
            const currentMaxX = targetX + root.width;
            const currentMaxY = targetY + root.height;

            // Handle snapping
            for (const snapTarget of root.monitorSnapTargets) {
                if (snapTarget.id === monitorID) {
                    continue;
                }

                const left = snapTarget.minX - currentMaxX;
                const right = snapTarget.maxX - currentMinX;
                const top = snapTarget.minY - currentMaxY;
                const bottom = snapTarget.maxY - currentMinY;

                // Level 1: Edge snapping
                if (left > 0 && left < snapDistanceX) {
                    snapX = snapTarget.minX - root.width;
                    snapDistanceX = left;
                }
                else if (right > 0 && right < snapDistanceX) {
                    snapX = snapTarget.maxX;
                    snapDistanceX = right;
                }
                if (top > 0 && top < snapDistanceY) {
                    snapY = snapTarget.minY - root.height;
                    snapDistanceY = top;
                }
                else if (bottom > 0 && bottom < snapDistanceY) {
                    snapY = snapTarget.maxY;
                    snapDistanceY = bottom;
                }

                // Level 2: Center snapping


                // Level 3: Corner snapping


            }

            root.x = snapX;
            root.y = snapY;
        }

        onActiveChanged: {
            if (!active) {
                root.monitorX = root.x
                root.monitorY = root.y

                root.moved(
                    root.monitorID,
                    root.monitorX,
                    root.monitorY,
                    root.monitorWidth,
                    root.monitorHeight
                )
            }
        }
    }
}