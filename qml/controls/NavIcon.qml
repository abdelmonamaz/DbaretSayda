import QtQuick
import QtQuick.Effects

// Colorizable SVG icon for navigation.
// Requires the SVG file at qrc:/icons/<iconType>.svg
// Color is applied via MultiEffect colorization (works with currentColor / black SVGs).
Item {
    id: root

    property string iconType:  "calendar-blank"
    property color  iconColor: Theme.colors.ink2
    property real   sz:        22

    implicitWidth:  sz
    implicitHeight: sz

    Image {
        anchors.fill: parent
        source:       "qrc:/icons/" + root.iconType + ".svg"

        // Render at 2× for crisp HiDPI display
        sourceSize.width:  root.sz * 2
        sourceSize.height: root.sz * 2

        fillMode:     Image.PreserveAspectFit
        smooth:       true
        antialiasing: true

        layer.enabled: true
        layer.effect: MultiEffect {
            colorization:      1.0
            colorizationColor: root.iconColor
        }
    }
}
