pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.modules.nexus.common

// One physical display gets its own card with basic settings (always visible)
// and an expandable "Advanced" section for more granular control.
// Matches hyprmod behavior where each monitor is its own config panel.

Rectangle {
    id: root

    required property string monitorName        // DP-3, HDMI-A-1, etc. (output / port in hyprland.conf)
    required property int monitorID             // hyprctl ID for IPC dispatch
    required property bool enabled
    required property string description        // model + make from hyprctl

    // Physical position of this monitor in the virtual desktop space
    property int monitorX: 0                    // absolute X position (used by DisplayLayout layout)
    property int monitorY: 0                    // absolute Y position used by MonitorConfigCard advanced section

    // Basic settings — defaults reflect current values from the system
    property var availableModes: []            // ["3840x2160@120.00Hz", ...] for monitor
    property int activeModeIndex: 0
    property real activeScale: 1
    property int activeRotation: 0

    // Advanced settings (initially collapsed)
    property bool advancedExpanded: false

    // serial number — matches hyprland.conf `monitor = ,<serial>,...` for persistent config
    // vs port-based matching where the output name must stay the same after cable re-plug
    property string serialNumber: ""           // unique hardware serial (empty when not resolved yet)

    implicitHeight: columnLayout.implicitHeight + padding * 2
    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.large
    opacity: enabled ? 1 : 0.5

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        anchors.margins: padding
        spacing: Tokens.spacing.small

        // ── Header row ────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            StyledText {
                Layout.fillWidth: true
                text: root.monitorName + (root.description ? " — " + root.description : "")
                font: Tokens.font.title.medium
                elide: Text.ElideRight
                color: Colours.tPalette.m3onSurfaceVariant
            }

            // Expand toggle for advanced section
            IconButton {
                Layout.alignment: Qt.AlignVCenter
                    icon: root.advancedExpanded ? "expand_less" : "expand_more"
                font: Tokens.font.icon.large
                invisibleOnHover: true
                inactiveColour: Colours.tPalette.m3primary
                inactiveOnColour: Colours.tPalette.m3onSurfaceVariant
                onClicked: root.advancedExpanded = !root.advancedExpanded
            }
        }

        // Separator between header and settings
        Item { Layout.preferredHeight: Tokens.padding.xxxSmall; Layout.fillWidth: true }

        // ── Basic settings (always visible) ───────────
        SectionHeader { text: qsTr("Basic") }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            // Enable toggle
            ToggleRow {
                Layout.fillWidth: true
                    text: qsTr("Enabled")
                    subtext: checked ? qsTr("Display is on") : qsTr("Display is off")
                    checked: root.enabled
            }

            // Resolution — uses hyprctl output-all-modes DP-1 data
            SelectRow {
                Layout.fillWidth: true
                label: qsTr("Resolution")
                menuItems: availableModes.map(m => ({text: m}))
                active: availableModes.length > 0 ? { text: availableModes[activeModeIndex] } : null

                onSelected: function(activeItem) {
                    if (activeItem) {
                    for (var i = 0; i < availableModes.length; i++) {
                        if (availableModes[i] === activeItem.text) {
                        activeModeIndex = i
                        break
                        }
                    }
                    }
                }
            }

            // Refresh rate — extracted from mode list strings like "3840x2160@120.00Hz"
            SelectRow {
                Layout.fillWidth: true
                label: qsTr("Refresh Rate")
                menuItems: availableModes.map(m => {
                    var match = m.match(/@([0-9.]+)Hz/)
                    return match ? { text: match[1] + " Hz" } : { text: m }
                })
                active: null

                onSelected: function(activeItem) {
                    if (activeItem) {
                    activeRefreshRate = parseFloat(activeItem.text) || -1
                    }
                }
            }

            // Orientation
            SelectRow {
                Layout.fillWidth: true
                label: qsTr("Orientation")
                menuItems: [
                    { text: qsTr("Landscape") },
                    { text: qsTr("Portrait-Right") },
                    { text: qsTr("Portrait-Left") },
                    { text: qsTr("Landscape-Flipped") }
                ]
                active: enabled ? { text: "Landscape" } : null

                onSelected: root.activeRotation = index
            }
        }

        // Separator before advanced section
        Item { Layout.preferredHeight: Tokens.padding.xxxSmall; Layout.fillWidth: true }

        // ── Advanced settings (collapsible) ───────────
        Rectangle {
            Layout.fillWidth: true
            visible: root.advancedExpanded

            color: Colours.tPalette.m3outlineVariant
            radius: Tokens.rounding.medium
            implicitHeight: advancedLayout.implicitHeight + padding * 2
            clip: true

            Behavior on opacity { Anim {} }

            ColumnLayout {
                id: advancedLayout
                anchors.fill: parent
                anchors.margins: padding
                visible: root.advancedExpanded
                spacing: Tokens.spacing.small

                SectionHeader { text: qsTr("Advanced") }

                // Position X/Y read-only (manually settable in hyprland.conf)
                InfoRow {
                    Layout.fillWidth: true
                    label: qsTr("Position X")
                    value: String(root._monitorX || 0)
                    icon: Icons.arrow_right_alt
                }

                InfoRow {
                    Layout.fillWidth: true
                    label: qsTr("Position Y")
                    value: String(root._monitorY || 0)
                    icon: Icons.arrow_upward
                }

                // Divider
                Item { 
                    Layout.preferredHeight: Tokens.padding.xxxSmall; 
                    Layout.fillWidth: true 
                }

                SectionHeader { text: qsTr("Colors") }

                ToggleRow {
                    Layout.fillWidth: true
                    text: qsTr("Adaptive Sync")
                    subtext: checked ? "Variable refresh rate enabled" : "Fixed refresh rate (VRR off)"
                    icon: Icons.sync
                    onToggled: console.log("Adaptive Sync toggled for", root.monitorName)
                }

                // HDR toggle (requires hyprctl --exit on some Hyprland versions)
                ToggleRow {
                    Layout.fillWidth: true
                    text: qsTr("HDR")
                    subtext: checked ? "HDR mode enabled" : "SDR mode"
                    onToggled: console.log("HDR toggled for", root.monitorName)
                }

                // Color range (full/limited)
                ToggleRow {
                    Layout.fillWidth: true
                    text: qsTr("Color Range")
                    subtext: checked ? "Full (0-255)" : "Limited (16-235)"
                    onToggled: console.log("Color range toggled for", root.monitorName)
                }

                // Brightness slider (requires compositing support)
                SliderRow {
                    Layout.fillWidth: true
                    label: qsTr("Brightness")
                    subtext: "Adjust display brightness"
                    icon: Icons.brightness_5
                    minimumValue: 0
                    maximumValue: 1
                    value: 0.9
                }

                // Contrast slider
                SliderRow {
                    Layout.fillWidth: true
                    label: qsTr("Contrast")
                    subtext: "Adjust display contrast"
                    icon: Icons.contrast
                    minimumValue: 0
                    maximumValue: 2
                    value: 1
                }

                // Gamma slider
                SliderRow {
                    Layout.fillWidth: true
                    label: qsTr("Gamma")
                    subtext: "Gamma correction"
                    icon: Icons.water_drop
                    minimumValue: 0.1
                    maximumValue: 3
                    value: 1
                }

                // Divider
                Item { 
                    Layout.preferredHeight: Tokens.padding.xxxSmall; 
                    Layout.fillWidth: true 
                }

                SectionHeader { text: qsTr("Hardware") }

                InfoRow {
                    Layout.fillWidth: true
                    label: qsTr("Port")
                    value: root.monitorName
                    icon: Icons.info_outline
                    subtext: "Output port (hyprland.conf `output` field)"
                }

                InfoRow {
                    visible: !!root.serialNumber
                    Layout.fillWidth: true
                    label: qsTr("Serial")
                    value: root.serialNumber
                    icon: Icons.info_outline
                    subtext: "Hardware serial (hyprland.conf `serial` field)"
                }

                InfoRow {
                    Layout.fillWidth: true
                    label: qsTr("Model")
                    value: root.description || qsTr("Unknown")
                    icon: Icons.info_outline
                }
            }
        }
    }
}
