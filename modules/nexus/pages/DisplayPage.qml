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

    // Display orientations (index 0 = landscape, 1 = portrait-right, 2 = portrait-left, 3 = landscape-flipped)
    readonly property list<MenuItem>  orientationItems: [
        MenuItem {
            text: qsTr("Landscape")
        },
        MenuItem {
            text: qsTr("Portrait-Right")
        },
        MenuItem {
            text: qsTr("Landscape-Left")
        },
        MenuItem {
            text: qsTr("Landscape-Flipped")
        }
    ]

    Component.onCompleted: {
        monitorProcess.running = true
    }

    // Display menu items — populated at runtime from hyprctl output.
    // Moved to PageBase scope so it's always accessible via root.displayItems;
    // ColumnLayout has no id, so the property can't be resolved from inside
    // StdioCollector.onStreamFinished otherwise.
    property var displayItems: []

    title: qsTr("Display")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            text: qsTr("Layout")
        }

        DisplayLayout {
            id: layout

            Layout.fillWidth: true

            display_model: root.monitorModel
        }

        SectionHeader {
            text: qsTr("Per display config")
        }

        SelectRow {
            first: true
            label: qsTr("Display")
            subtext: qsTr("Applying settings to this display")
            menuItems: displayItems
            //active: displayItems.length > 0 ? displayItems[0] : null
            //onSelected:
        }

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
            //subtext: qsTr("")
            menuItems: root.orientationItems
            active: root.orientationItems[0]
            //onSelected:
        }

        SelectRow {
            label: qsTr("Refresh Rate")
            //subtext: qsTr("")
            menuItems: root.orientationItems
            active: root.orientationItems[0]
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
                    root.monitorModel = JSON.parse(text).map(monitor => ({
                        _monitorName: monitor.model,
                        _monitorID: monitor.id,
                        _monitorX: monitor.x,
                        _monitorY: monitor.y,
                        _monitorWidth: monitor.width,
                        _monitorHeight: monitor.height,
                        _monitorScale: monitor.scale
                    }))

                    let items = []

                    for (const monitor of root.monitorModel) {
                       items.push(
                          menuItemComponent.createObject(null, {
                              text: monitor._monitorName
                          })
                       )
                    }

                    root.displayItems = items

                    layout.fitDisplays()
                }
            }
        }
    }
}