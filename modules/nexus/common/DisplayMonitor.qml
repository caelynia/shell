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

    property bool selected: false;
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
    border.width: selected ? 28 : 20
    border.color: selected
        ? Colours.tPalette.m3primary
        : Colours.tPalette.m3outline

    Behavior on border.width {
        NumberAnimation { duration: 60 }
    }

    Behavior on x {
        NumberAnimation {
            duration: 70
            easing.type: Easing.OutQuad
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 70
            easing.type: Easing.OutQuad
        }
    }

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

            const currentMinX = targetX;
            const currentMinY = targetY;
            const currentMaxX = targetX + root.width;
            const currentMaxY = targetY + root.height;

            // Handle snapping
            for (const snapTarget of root.monitorSnapTargets) {
                if (snapTarget.id === monitorID)
                    continue;

                const targetMinX = snapTarget.minX;
                const targetMaxX = snapTarget.maxX;
                const targetCenterX = (targetMinX + targetMaxX) / 2;

                const targetMinY = snapTarget.minY;
                const targetMaxY = snapTarget.maxY;
                const targetCenterY = (targetMinY + targetMaxY) / 2;

                const currentCenterX = (currentMinX + currentMaxX) / 2;
                const currentCenterY = (currentMinY + currentMaxY) / 2;

                // X alignments
                const xCandidates = [
                    // Edge - Edge
                    targetMinX - currentMinX,
                    targetMinX - currentMaxX,
                    targetMaxX - currentMinX,
                    targetMaxX - currentMaxX,

                    // Center - Center
                    targetCenterX - currentCenterX
                ];

                for (const dx of xCandidates) {
                    const distance = Math.abs(dx);

                    if (distance < snapDistanceX) {
                        snapDistanceX = distance;
                        snapX = targetX + dx;
                    }
                }

                // Y alignments
                const yCandidates = [
                    // Edge - Edge
                    targetMinY - currentMinY,
                    targetMinY - currentMaxY,
                    targetMaxY - currentMinY,
                    targetMaxY - currentMaxY,

                    // Center - Center
                    targetCenterY - currentCenterY
                ];

                for (const dy of yCandidates) {
                    const distance = Math.abs(dy);

                    if (distance < snapDistanceY) {
                        snapDistanceY = distance;
                        snapY = targetY + dy;
                    }
                }
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