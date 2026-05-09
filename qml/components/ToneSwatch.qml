import QtQuick
import QtQuick.Effects

Rectangle {
    id: toneSwatch

    property string selectedTone: 'harissa'
    property int    size:         30

    signal toneSelected(string toneName)

    color: 'transparent'

    implicitWidth:  childrenRect.width
    implicitHeight: childrenRect.height

    Flow {
        spacing: Theme.sizes.md

        Repeater {
            model: Theme.toneNames

            Rectangle {
                id: swatch
                width:  size
                height: size
                radius: size / 2

                readonly property string toneName:  modelData
                readonly property bool   isSelected: toneName === selectedTone

                color:        Theme.getTone(toneName).main
                border.color: isSelected ? Theme.colors.ink  : Theme.colors.ink3
                border.width: isSelected ? 2.5 : 1

                layer.enabled: isSelected
                layer.effect: MultiEffect {
                    shadowEnabled:  true
                    shadowColor:    Theme.colors.bone2
                    shadowBlur:     0.4
                    shadowOpacity:  0.8
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedTone = toneName
                        toneSelected(toneName)
                    }
                }
            }
        }
    }
}
