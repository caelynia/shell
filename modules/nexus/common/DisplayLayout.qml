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

    property var snapTargets: []
    property var displayMonitors: []

    property int selectedMonitor: -1

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

    implicitWidth: displayWidth
    implicitHeight: displayHeight

    Item {
        id: canvas

        x: root.displayPanX
        y: root.displayPanY
        scale: root.displayScale

        Repeater {
            id: repeater2

            model: root.display_model

            delegate: DisplayMonitor {
                id: monitor

                required property string _monitorName
                required property string _monitorID
                required property int _monitorX
                required property int _monitorY
                required property int _monitorWidth
                required property int _monitorHeight
                required property real _monitorScale

                monitorName: _monitorName
                monitorID: _monitorID

                monitorX: _monitorX
                monitorY: _monitorY

                monitorWidth: _monitorWidth
                monitorHeight: _monitorHeight

                monitorScale: _monitorScale

                selected: root.selectedMonitor === monitorID

                monitorSnapTargets: snapTargets

                Component.onCompleted: {
                    root.displayMonitors.push(monitor)
                }

                Component.onDestruction: {
                    const index = root.displayMonitors.indexOf(monitor)
                    if (index !== -1) {
                        root.displayMonitors.splice(index, 1)
                    }
                }

                onPressed: id => {
                    root.selectedMonitor = id;
                    gatherSnapPositions(id)
                }
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
        acceptedButtons: Qt.MiddleButton | Qt.RightButton

        property real lastX: 0
        property real lastY: 0

        onPressed: event => {
            if (event.button === Qt.LeftButton) {
                root.selectedMonitor = -1;
            }
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
        if (!root.display_model || root.display_model.length === 0) {
            return;
        }

        let minX = Infinity;
        let minY = Infinity;
        let maxX = -Infinity;
        let maxY = -Infinity;

        for (const display of root.display_model) {
            minX = Math.min(minX, display._monitorX);
            minY = Math.min(minY, display._monitorY);

            maxX = Math.max(maxX, display._monitorX + display._monitorWidth / display._monitorScale);
            maxY = Math.max(maxY, display._monitorY + display._monitorHeight / display._monitorScale);
        }

        const worldWidth = maxX - minX;
        const worldHeight = maxY - minY;

        const coverPercentage = 0.7;

        const scaleX = (root.width * coverPercentage) / worldWidth;
        const scaleY = (root.height * coverPercentage) / worldHeight;

        const newScale = root.clampScale(Math.min(scaleX, scaleY));

        const centerX = minX + worldWidth / 2;
        const centerY = minY + worldHeight / 2;

        const newPanX = root.width / 2 - centerX * newScale;
        const newPanY = root.height / 2 - centerY * newScale;

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

        gatherSnapPositions();
    }

    // Calculates the snapping positions of the other monitors
    function gatherSnapPositions() {
        snapTargets.length = 0

        for (const display of root.displayMonitors) {

            if (!display) {
                continue;
            }

            const x = display.monitorX;
            const y = display.monitorY;
            const width = display.monitorWidth / display.monitorScale;
            const height = display.monitorHeight / display.monitorScale;

            const i = display.monitorID;
            const left = x;
            const top = y;
            const right = x + width;
            const bottom = y + height;

            snapTargets.push({id: i, minX: left, minY: top, maxX: right, maxY: bottom });
        }
    }
}