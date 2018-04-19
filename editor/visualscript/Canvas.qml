import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2

Item {
    id: root
    property var objectTypesModel
    property var _objectTypes
    property var _objects

    Component.onCompleted: {
        _objects = {};
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        border.color: "gray"
        border.width: 1
        color: "lightgray"

        DropArea {
            anchors.fill: parent
            onDropped: {
                var model = root._objectTypes[drop.text];
                var newObject = object.createObject(container, {"x": drop.x - 110, "y": drop.y - (16 + (model.inputs.count > 0 ? 6 : 0)), "model": model});
                root._objects[newObject] = newObject;
                container.selected = newObject;
                drop.accept(Qt.CopyAction);
            }
        }

        Flickable {
            id: container
            property var selected: null
            property var connections: []
            anchors.fill: parent
            anchors.margins: 2
            ScrollBar.vertical: ScrollBar {
                parent: container.parent
                anchors.top: container.top
                anchors.left: container.right
                anchors.bottom: container.bottom
            }
            ScrollBar.horizontal: ScrollBar { }
            clip: true

            Canvas {
                anchors.fill: parent
                contextType: "2d"
                onPaint: {
                    context.strokeStyle = Qt.rgba(.4,.6,.8);
                    context.path = myPath;
                    context.stroke();
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: container.selected = null
            }

            Component {
                id: object
                Object {
                    isSelected: container.selected === this
                    onObjectSelected: container.selected = this
                }
            }
        }
    }

    onObjectTypesModelChanged: {
        var types = {};
        for (var idx=0; idx<objectTypesModel.count; ++idx) {
            var type = objectTypesModel.get(idx);
            types[type.name] = type;
        }
        _objectTypes = types;
    }

    function deleteSelected() {
        if (container.selected !== null) {
            delete root._objects[container.selected];
            container.selected.destroy();
            container.selected = null;
        }
    }

    function serialise() {
        var data = [];
        for (var key in root._objects) {
            var object = root._objects[key];
            data.push({x: object.x, y: object.y, type: object.model.name});
        }
        return data;
    }
    function unserialise(data) {

    }
}
