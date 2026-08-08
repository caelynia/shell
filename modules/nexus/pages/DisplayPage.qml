pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    property var monitorModel: []
    
    readonly property list<MenuItem> orientationItems: [
        MenuItem { text: qsTr("Landscape") },
        MenuItem { text: qsTr("Portrait-Right") },
        MenuItem { text: qsTr("Portrait-Left") },
        MenuItem { text: qsTr("Landscape-Flipped") }
    ]

    Component.onCompleted: {
        monitorProcess.running = true
    }

    title: qsTr("Display")

    ListModel {
        id: displayModeList
        onCountChanged: layout.fitDisplays()
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        
        SectionHeader { text: qsTr("Layout") }

        DisplayLayout {
            id: layout

            Layout.fillWidth: true

            display_model: root.monitorModel
        }

        SectionHeader { text: qsTr("Per display config") }

        // ── Grid of per-monitor cards (one like hyprmod) ───
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall
            
            Repeater {
                model: root.monitorModel
                
                MonitorConfigCard {
                    Layout.fillWidth: true
                    
                    monitorName:   _monitorName
                    monitorID:     _monitorID
                    enabled:       true  // TODO: read current state from hyprctl
                    description:   ""  // TODO: populate with model+make from hyprctl
                    
                    monitorX:      _monitorX
                    monitorY:      _monitorY
                    
                    availableModes: []  // TODO: fetch with hyprctl output-all-modes DP-1
                    
                    // Position info passed to advanced section
                    monitorX: _monitorX
                    monitorY: _monitorY
                }
            }
        }

        Component.onCompleted: {
            // This block will be moved into the Process handler instead
            displayModeList.clear()
            
            for (var i = displayItems.length - 1; i >= 0; --i) {
                if (displayItems[i].selected) {
                    displayMoveItem.move(i, 0)
                    break
                }
            }
        }

        // ── Display selector / active monitor picker ───────
        SelectRow {
            first: true
            label: qsTr("Display")
            subtext: qsTr("Applying settings to this display")
            menuItems: displayItems
            //active: displayItems.length > 0 ? displayItems[0] : null
            //onSelected:
        }

        SectionHeader { text: qsTr("Monitor Settings") }

        ToggleRow {
            text: qsTr("Enabled")
            subtext: qsTr("Whether the display should be turned on or off")
            enabled: true
            opacity: true ? 1 : 0.5
            //checked:
            onToggled: {

            }

            Behavior on opacity {
                Anim {}
            }
        }

        SelectRow {
            label: qsTr("Orientation")
            menuItems: orientationItems
            active: orientationItems[0]
            //onSelected:
        }

        SelectRow {
            label: qsTr("Refresh Rate")
            menuItems: orientationItems
            active: orientationItems[0]
            //onSelected:
        }

        Component {
            id: menuItemComponent
            MenuItem {}
        }

        Process {
            id: monitorProcess

            command: ["hyprctl", "monitors", "-j"]

            stdout: StdioCollector {
                onStreamFinished: {
                    root.monitorModel = JSON.parse(text).map(function(monitor) {
                        return {
                            _monitorName: monitor.model,
                            _monitorID: monitor.id,
                            _monitorX: monitor.x,
                            _monitorY: monitor.y,
                            _monitorWidth: monitor.width,
                            _monitorHeight: monitor.height,
                            _monitorScale: monitor.scale
                        }
                    })

                    var items = []

                    for (var i = 0; i < root.monitorModel.length; ++i) {
                       var item = menuItemComponent.createObject(null, {
                           text: root.monitorModel[i]._monitorName
                       })
                       items.push(item)
                    }

                    displayItems = items
                    
                    layout.fitDisplays()
                }
            }
        }
    }
}
