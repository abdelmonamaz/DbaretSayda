import QtQuick

Rectangle {
    id: thumb

    property string tone:     'harissa'
    property string label:    "Plat"
    property string imageUri: ""
    property int    size:     56

    width:  size
    height: size
    radius: Theme.sizes.radius.xl

    readonly property color toneColor: Theme.getTone(tone).main
    color: toneColor

    Image {
        anchors.fill: parent
        source: imageUri
        fillMode: Image.PreserveAspectCrop
        visible: imageUri.length > 0 && status === Image.Ready
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height: 18
        color:  Qt.rgba(0, 0, 0, 0.3)

        Text {
            anchors.centerIn: parent
            text: label
            color: Theme.colors.bone
            font.pixelSize: Theme.typography.dishLabelSize
            font.family:    Theme.typography.fontMono
            elide: Text.ElideRight
            width: parent.width - Theme.sizes.xs
        }
    }
}
