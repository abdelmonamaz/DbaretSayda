import QtQuick

Rectangle {
    id: button

    required property string text
    property string variant: 'primary'   // primary | secondary | danger | ghost
    property string size:    'md'        // sm | md | lg

    // Do NOT redeclare `enabled` — Item.enabled is inherited and works fine

    signal clicked()

    readonly property color bgColor:     _getBg()
    readonly property color textColor:   _getText()
    readonly property color borderColor: _getBorder()

    function _getBg() {
        if (!enabled) return Theme.colors.bone2
        switch(variant) {
            case 'primary':   return Theme.colors.harissa.main
            case 'secondary': return Theme.colors.bone2
            case 'danger':    return Theme.colors.harissa.deep
            case 'ghost':     return 'transparent'
            default:          return Theme.colors.harissa.main
        }
    }
    function _getText() {
        switch(variant) {
            case 'primary': case 'danger': return Theme.colors.card
            default:                       return Theme.colors.ink
        }
    }
    function _getBorder() {
        return variant === 'ghost' ? Theme.colors.ink2 : 'transparent'
    }

    // Use implicitHeight so we don't shadow the final `height` property
    implicitHeight: size === 'sm' ? 24 : (size === 'lg' ? 40 : 32)
    implicitWidth:  Math.max(80, label.implicitWidth + Theme.sizes.xxl)

    color:        bgColor
    radius:       Theme.sizes.radius.xl
    border.color: borderColor
    border.width: variant === 'ghost' ? 1 : 0
    opacity:      enabled ? 1.0 : 0.5

    MouseArea {
        anchors.fill: parent
        enabled: button.enabled
        onClicked: button.clicked()
    }

    Text {
        id: label
        anchors.centerIn: parent
        text:            button.text
        color:           textColor
        font.pixelSize:  Theme.typography.buttonSize
        font.family:     Theme.typography.fontUI
        font.bold: true
    }
}
