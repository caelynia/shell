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

    property real panX: 0
    property real panY: 0

    property real displayPanX: panX
    property real displayPanY: panY

    readonly property int displayWidth: 700
    readonly property int displayHeight: 350

    property real effectiveScale: 0.12
    property real displayScale: effectiveScale

    property bool enableAnimations: false

    Component.onCompleted: {
        Qt.callLater(root.fitDisplays)
    }

    Behavior on displayPanX {
        enabled: root.enableAnimations
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Behavior on displayPanY {
        enabled: root.enableAnimations
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Behavior on displayScale {
        enabled: root.enableAnimations
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutBack
            easing.overshoot: 1.15
        }
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

    // Clamps the value between min scale and max scale
    function clampScale(value) {
        return Math.max(root.minimumScale, Math.min(root.maximumScale, value))
    }

    // Calculate perfect viewport to fit all displays
    function fitDisplays() {
        if (!display_model || display_model.count === 0) {
            return;
        }

        let minX = Infinity;
        let minY = Infinity;
        let maxX = -Infinity;
        let maxY = -Infinity;

        for (let i = 0; i < display_model.count; i++) {
            const display = display_model.get(i);

            minX = Math.min(minX, display.xPos);
            minY = Math.min(minY, display.yPos);

            maxX = Math.max(maxX, display.xPos + display.screenWidth);
            maxY = Math.max(maxY, display.yPos + display.screenHeight);
        }

        const worldWidth = maxX - minX;
        const worldHeight = maxY - minY;

        const coverPercentage = 0.8;

        const scaleX = (root.displayWidth * coverPercentage) / worldWidth;
        const scaleY = (root.displayHeight * coverPercentage) / worldHeight;

        const newScale = root.clampScale(Math.min(scaleX, scaleY));

        const centerX = minX + worldWidth / 2;
        const centerY = minY + worldHeight / 2;

        const newPanX = root.displayWidth / 2 - centerX * newScale;
        const newPanY = root.displayHeight / 2 - centerY * newScale;

        if (!root.enableAnimations) {
            // Set initial position (for animation)
            root.panX = newPanX;
            root.panY = newPanY;
            root.effectiveScale = newScale * 2;

            root.displayPanX = root.panX;
            root.displayPanY = root.panY;
            root.displayScale = root.effectiveScale;

            root.enableAnimations = true
        }

        root.panX = newPanX;
        root.panY = newPanY;
        root.effectiveScale = newScale;

        root.displayPanX = root.panX;
        root.displayPanY = root.panY;
        root.displayScale = root.effectiveScale;
    }
}