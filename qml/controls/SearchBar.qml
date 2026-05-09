import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: searchBar

    property string text:        ""
    property string placeholder: (I18n.currentLanguage, I18n.t('dishes.search'))

    signal searchChanged(string newText)
    signal cleared()

    color:          Theme.colors.card
    radius:         14
    border.color:   "#141B1714"   // rgba(27,23,20,0.08)
    border.width:   1
    implicitHeight: 44

    RowLayout {
        anchors {
            fill:         parent
            leftMargin:   14
            rightMargin:  10
            topMargin:    10
            bottomMargin: 10
        }
        spacing: 10

        // Search icon
        Image {
            width:      15
            height:     15
            source:     "qrc:/icons/search.svg"
            sourceSize: Qt.size(30, 30)
            fillMode:   Image.PreserveAspectFit
            Layout.alignment: Qt.AlignVCenter

            layer.enabled: true
            layer.effect: MultiEffect {
                colorization:      1.0
                colorizationColor: Theme.colors.ink3
            }
        }

        // Text input + placeholder overlay
        Item {
            Layout.fillWidth:  true
            Layout.fillHeight: true

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible:        inputField.text.length === 0
                text:           searchBar.placeholder
                font.pixelSize: 15
                font.family:    Theme.typography.fontUI
                color:          Theme.colors.ink3
            }

            TextInput {
                id:                inputField
                anchors.fill:      parent
                text:              searchBar.text
                font.pixelSize:    15
                font.family:       Theme.typography.fontUI
                color:             Theme.colors.ink
                verticalAlignment: TextInput.AlignVCenter
                clip:              true

                onTextEdited: {
                    searchBar.text = text
                    searchBar.searchChanged(text)
                }
            }
        }

        // Clear ×
        Item {
            width:   18
            height:  18
            visible: searchBar.text.length > 0
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text:           "×"
                font.pixelSize: 16
                color:          Theme.colors.ink3
                font.family:    Theme.typography.fontUI
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    searchBar.text = ""
                    inputField.text = ""
                    searchBar.cleared()
                    searchBar.searchChanged("")
                }
            }
        }
    }
}
