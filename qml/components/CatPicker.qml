import QtQuick
import QtQuick.Layouts

Rectangle {
    id: catPicker

    property string selectedCategory: 'main'

    signal categorySelected(string category)

    color: 'transparent'
    implicitHeight: 60

    readonly property var categories: (I18n.currentLanguage, [
        { id: 'starter', label: I18n.t('dishes.categories.starter'), icon: '🌿', color: Theme.colors.olive.main },
        { id: 'main',    label: I18n.t('dishes.categories.main'),    icon: '🍲', color: Theme.colors.harissa.main },
        { id: 'dessert', label: I18n.t('dishes.categories.dessert'), icon: '🍰', color: Theme.colors.makroudh.main }
    ])

    GridLayout {
        anchors.fill:  parent
        columns:       3
        columnSpacing: Theme.sizes.md
        rowSpacing:    Theme.sizes.sm

        Repeater {
            model: categories

            Rectangle {
                id: catButton
                Layout.fillWidth:  true
                Layout.fillHeight: true

                readonly property string catId:      modelData.id
                readonly property bool   isSelected: catId === selectedCategory

                color:        isSelected ? modelData.color : Theme.colors.bone2
                radius:       Theme.sizes.radius.lg
                border.color: isSelected ? modelData.color : Theme.colors.line
                border.width: isSelected ? 2 : 1

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.sizes.xs

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.icon
                        font.pixelSize: 20
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.label
                        color: isSelected ? Theme.colors.card : Theme.colors.ink
                        font.pixelSize: Theme.typography.tagSize
                        font.family:    Theme.typography.fontUI
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedCategory = catId
                        categorySelected(catId)
                    }
                }
            }
        }
    }
}
