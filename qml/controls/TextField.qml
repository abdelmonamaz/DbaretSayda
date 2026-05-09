import QtQuick

Rectangle {
    id: textField

    property string text:        ""
    property string placeholder: ""
    property string lang:        'fr'
    property bool   multiline:   false
    property bool   enabled:     true

    signal textChanged(string newText)

    readonly property alias input: textInput

    color:        Theme.colors.card
    border.color: Theme.colors.line
    border.width: 1
    radius:       Theme.sizes.radius.lg
    height:       multiline ? 80 : Theme.sizes.componentMd

    TextInput {
        id: textInput
        anchors {
            left:          parent.left
            right:         parent.right
            verticalCenter: parent.verticalCenter
            margins:       Theme.sizes.lg
        }

        text:            textField.text
        placeholderText: textField.placeholder
        font.pixelSize:  Theme.typography.inputSize
        font.family:     Theme.typography.fontUI
        color:           Theme.colors.ink
        enabled:         textField.enabled

        horizontalAlignment: lang === 'ar' ? Text.AlignRight : Text.AlignLeft

        onTextChanged: textField.textChanged(text)
    }
}
