import QtQuick
import QtQuick.Effects

Item {
    id: filterChips

    // Multi-selection — array of selected filter ids
    property var    activeFilters: []
    signal filterChanged(var filters)

    // Show week range line below chips (true for HomePage)
    property bool showWeekRange: false

    implicitHeight: chipsRow.height + (showWeekRange ? rangeText.implicitHeight + 10 : 0)

    // ── ISO week range ────────────────────────────────────────────────────────
    function weekRange() {
        var d = new Date()
        var day = d.getDay()
        var diff = d.getDate() - day + (day === 0 ? -6 : 1)
        var mon = new Date(d.getFullYear(), d.getMonth(), diff)
        var sun = new Date(d.getFullYear(), d.getMonth(), diff + 6)

        if (I18n.currentLanguage === 'ar') {
            var arM = ["يناير","فبراير","مارس","أبريل","ماي","يونيو",
                       "يوليو","أغسطس","سبتمبر","أكتوبر","نوفمبر","ديسمبر"]
            return I18n.formatNumber(mon.getDate()) + " → " + I18n.formatNumber(sun.getDate())
                 + " " + arM[sun.getMonth()] + " · " + I18n.formatNumber(7)
                 + " " + I18n.t('filter.days')
        }
        var frM = ["JAN","FÉV","MAR","AVR","MAI","JUN",
                   "JUL","AOÛ","SEP","OCT","NOV","DÉC"]
        return mon.getDate() + " → " + sun.getDate()
             + " " + frM[sun.getMonth()]
             + " · 7 " + I18n.t('filter.days').toUpperCase()
    }

    // ── Chip definitions ──────────────────────────────────────────────────────
    readonly property var chips: [
        { id: 'starter', icon: 'soup-bowl',  labelKey: 'dishes.categories.starter' },
        { id: 'main',    icon: 'dish',        labelKey: 'dishes.categories.main'    },
        { id: 'dessert', icon: 'cake-3-line', labelKey: 'dishes.categories.dessert' }
    ]

    Column {
        anchors.fill: parent
        spacing: 10

        // ── Chip row ──────────────────────────────────────────────────────────
        Row {
            id:      chipsRow
            width:   parent.width
            height:  80
            spacing: 8

            Repeater {
                model: filterChips.chips

                Rectangle {
                    id:     chip
                    width:  (chipsRow.width - 16) / 3
                    height: chipsRow.height
                    radius: 18

                    readonly property bool isActive: filterChips.activeFilters.indexOf(modelData.id) !== -1

                    // Palette per category
                    readonly property color bgSoft: modelData.id === 'starter' ? Theme.colors.olive.soft
                                                  : modelData.id === 'main'    ? Theme.colors.harissa.soft
                                                  :                              Theme.colors.rose.soft
                    readonly property color bgMain: modelData.id === 'starter' ? Theme.colors.olive.main
                                                  : modelData.id === 'main'    ? Theme.colors.harissa.main
                                                  :                              Theme.colors.rose.main
                    readonly property color bgDeep: modelData.id === 'starter' ? Theme.colors.olive.deep
                                                  : modelData.id === 'main'    ? Theme.colors.harissa.deep
                                                  :                              Theme.colors.rose.deep

                    // Selected  → bgSoft bg  + bgDeep border
                    // Unselected → white bg   + gray border
                    color:        isActive ? bgSoft          : Theme.colors.card
                    border.color: isActive ? bgDeep          : Theme.colors.line
                    border.width: isActive ? 2               : 1

                    Column {
                        anchors {
                            left:   parent.left
                            top:    parent.top
                            leftMargin: 12
                            topMargin:  12
                        }
                        spacing: 6

                        // Icon circle
                        // Selected  → bgDeep circle + white icon
                        // Unselected → bgSoft circle + bgMain icon
                        Rectangle {
                            width:  36
                            height: 36
                            radius: 18
                            color:  chip.isActive ? chip.bgDeep : chip.bgSoft

                            Image {
                                anchors.centerIn: parent
                                width:      18
                                height:     18
                                source:     "qrc:/icons/" + modelData.icon + ".svg"
                                sourceSize: Qt.size(36, 36)
                                fillMode:   Image.PreserveAspectFit
                                smooth:     true

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization:      1.0
                                    colorizationColor: chip.isActive ? "#ffffff" : chip.bgMain
                                }
                            }
                        }

                        // Category name
                        Text {
                            width:          chip.width - 24
                            text:           (I18n.currentLanguage, I18n.t(modelData.labelKey))
                            font.pixelSize: 13
                            font.family:    Theme.typography.fontUI
                            font.weight:    Font.Bold
                            color:          Theme.colors.ink
                            wrapMode:       Text.Wrap
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var arr = filterChips.activeFilters.slice()
                            var idx = arr.indexOf(modelData.id)
                            if (idx !== -1) arr.splice(idx, 1)
                            else            arr.push(modelData.id)
                            filterChips.activeFilters = arr
                            filterChips.filterChanged(arr)
                        }
                    }
                }
            }
        }

        // ── Week range ────────────────────────────────────────────────────────
        Text {
            id:               rangeText
            visible:          filterChips.showWeekRange
            width:            parent.width
            text:             filterChips.weekRange()
            font.pixelSize:   11
            font.family:      Theme.typography.fontMono
            font.weight:      Font.DemiBold
            font.letterSpacing: 1.76   // 0.16em × 11px
            font.capitalization: Font.AllUppercase
            color:            Theme.colors.ink3
        }
    }
}
