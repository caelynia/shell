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

    // Create model in JS to avoid the default property capture issue
    readonly property var monitorModel: (function() {
        var model = new ListModel();
        model.append({ name: "Monitor 1", xPos: 0, yPos: 0, width: 1920, height: 1080 });
        model.append({ name: "Monitor 2", xPos: 1920, yPos: 200, width: 2560, height: 1440 });
        model.append({ name: "Monitor 3", xPos: -1280, yPos: 100, width: 1280, height: 1024 });
        return model;
    })()

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: root.cappedWidth

        spacing: 8

        SectionHeader {
            text: qsTr("Display Layout")
        }

        DisplayLayout {
            Layout.fillWidth: true
            display_model: root.monitorModel
        }
    }
}
