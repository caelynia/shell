import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Display")

    ColumnLayout {
        ListModel {
            id: monitorModel

            ListElement {
                name: "Monitor 1"
                xPos: 0
                yPos: 0
                screenWidth: 1920
                screenHeight: 1080
            }

            ListElement {
                name: "Monitor 2"
                xPos: 1920
                yPos: 200
                screenWidth: 2560
                screenHeight: 1440
            }

            ListElement {
                name: "Monitor 3"
                xPos: -1280
                yPos: 100
                screenWidth: 1280
                screenHeight: 1024
            }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: root.cappedWidth

        spacing: 8

        SectionHeader {
            text: qsTr("Layout")
        }

        DisplayLayout {
            id: layout

            Layout.fillWidth: true

            display_model: monitorModel
        }
    }
}
