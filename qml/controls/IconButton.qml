import QtQuick

/**
 * Icon ButtonDS Component
 * Props:
 *  - icon: icon character/emoji or symbol
 *  - size: 'sm', 'md', 'lg' (default: 'md')
 *  - color: icon color (default: ink)
 *  - onClicked(): signal
 */
Rectangle {
    id: iconButton
    
    required property string icon
    property string size: 'md'              // sm, md, lg
    property color iconColor: Theme.colors.ink
    
    signal clicked()
    
    readonly property int dimension: getSize()
    
    function getSize() {
        switch(size) {
            case 'sm': return Theme.sizes.componentSm
            case 'md': return Theme.sizes.componentMd
            case 'lg': return Theme.sizes.componentLg
            default: return Theme.sizes.componentMd
        }
    }
    
    width: dimension
    height: dimension
    color: 'transparent'
    radius: Theme.sizes.radius.md
    
    MouseArea {
        anchors.fill: parent
        onClicked: iconButton.clicked()
    }
    
    Text {
        anchors.centerIn: parent
        text: icon
        font.pixelSize: dimension * 0.5
        color: iconColor
    }
}
