import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: slot

    property string type:       'main'
    property string dishName:   ""
    property string dishNameAr: ""
    property int    dishId:     -1
    property string tone:       "harissa"

    signal swapped()
    signal removed()
    signal dishInfoRequested()

    readonly property bool   isEmpty:      dishName === "" || dishId <= 0
    readonly property string displayName:  ((I18n.currentLanguage === 'ar') && dishNameAr) ? dishNameAr : dishName
    readonly property bool isMain:  type === 'main'

    // ── Per-type palette ──────────────────────────────────────────────────
    readonly property color accentColor: {
        if (type === 'starter') return "#6B9A50"        // oklch(0.58 0.1 130)
        if (type === 'main')    return Theme.colors.harissa.main
        return "#D49585"                                // oklch(0.78 0.1 18)
    }
    readonly property color ringColor: {
        if (type === 'starter') return "#D5ECC8"        // oklch(0.94 0.04 130)
        return "#F5E4E0"                                // oklch(0.96 0.03 20)
    }

    readonly property string slotLabel: {
        I18n.currentLanguage  // reactive dependency
        if (type === 'starter') return I18n.t('dishes.categories.starter')
        if (type === 'main')    return I18n.t('dishes.categories.main')
        return I18n.t('dishes.categories.dessert')
    }

    color:          isMain ? Theme.getTone(slot.tone).soft : "transparent"
    radius:         12
    clip:           true
    implicitHeight: isMain ? 68 : 42

    RowLayout {
        anchors {
            fill:         parent
            leftMargin:   10
            rightMargin:  8
            topMargin:    isMain ? 8 : 6
            bottomMargin: isMain ? 8 : 6
        }
        spacing: 12

        // ── Left icon / thumbnail ─────────────────────────────────────────
        Item {
            implicitWidth:  isMain ? 48 : 24
            implicitHeight: isMain ? 48 : 24
            Layout.alignment: Qt.AlignVCenter

            // Ring + dot (starter / dessert)
            Rectangle {
                visible:          !isMain
                anchors.centerIn: parent
                width: 24; height: 24; radius: 12
                color: slot.ringColor

                Rectangle {
                    anchors.centerIn: parent
                    width: 16; height: 16; radius: 8
                    color: slot.accentColor
                }
            }

            // Dish thumbnail (main)
            DishThumb {
                visible: isMain
                size:    48
                radius:  11
                label:   slot.displayName.length > 0
                             ? ((I18n.currentLanguage === 'ar') ? slot.displayName.substring(0, 4)
                                           : slot.displayName.substring(0, 6).toUpperCase())
                             : "···"
                tone:    slot.tone
            }
        }

        // ── Text column ───────────────────────────────────────────────────
        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: isMain ? 2 : 1

            Text {
                text:                (I18n.currentLanguage === 'ar') ? slot.slotLabel : slot.slotLabel.toUpperCase()
                color:               slot.accentColor
                font.pixelSize:      10
                font.family:         Theme.typography.fontUI
                font.weight:         Font.DemiBold
                font.letterSpacing:  1.4    // 0.14em × 10
                font.capitalization: Font.AllUppercase
            }

            Text {
                width:              parent.width
                text:               isEmpty ? "—" : slot.displayName
                color:              isEmpty ? Theme.colors.ink3 : Theme.colors.ink
                font.pixelSize:     isMain ? 17 : 14
                font.family:        (I18n.currentLanguage === 'ar') ? "Tajawal" : Theme.typography.fontUI
                font.weight:        isMain ? Font.Bold : Font.Medium
                font.letterSpacing: isMain ? -0.17 : 0
                elide:              Text.ElideRight
            }
        }

        // ── Swap button ───────────────────────────────────────────────────
        Item {
            implicitWidth:  28
            implicitHeight: 28
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                width:      14
                height:     14
                source:     "qrc:/icons/refresh.svg"
                sourceSize: Qt.size(28, 28)
                fillMode:   Image.PreserveAspectFit
                smooth:     true

                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization:      1.0
                    colorizationColor: Theme.colors.ink3
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked:    slot.swapped()
            }
        }
    }

    // Tap sur la zone gauche (nom du plat) → popup ingrédients
    MouseArea {
        anchors {
            left: parent.left; top: parent.top; bottom: parent.bottom
            right: parent.right; rightMargin: 44
        }
        enabled: !slot.isEmpty
        onClicked: slot.dishInfoRequested()
    }
}
