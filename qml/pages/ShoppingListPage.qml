import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: shoppingPage
    color: Theme.colors.bone

    // ── State ─────────────────────────────────────────────────────────────
    property var _allItems:   []
    property var _checkedSet: ({})   // ingredientId → bool

    function reload() {
        var items = shoppingListModel.allAsVariantList()
        _allItems = items
        var cs = {}
        for (var i = 0; i < items.length; i++)
            cs[items[i].ingredientId] = items[i].isChecked
        _checkedSet = cs
    }

    Component.onCompleted: reload()

    Connections {
        target: shoppingListModel
        function onModelReset() { shoppingPage.reload() }
    }

    readonly property int totalCount: _allItems.length

    readonly property int checkedCount: {
        var n = 0
        var keys = Object.keys(_checkedSet)
        for (var i = 0; i < keys.length; i++) if (_checkedSet[keys[i]]) n++
        return n
    }

    readonly property var _groups: {
        var groups = [], curGroup = null
        for (var i = 0; i < _allItems.length; i++) {
            var item = _allItems[i]
            if (!curGroup || item.category !== curGroup.cat) {
                curGroup = { cat: item.category, dotColor: catDotColor(item.category), items: [] }
                groups.push(curGroup)
            }
            curGroup.items.push(item)
        }
        return groups
    }

    function catDotColor(cat) {
        return ({"VEGETABLE":"#6B9A50","SPICE":"#E0C660","MEAT":"#E75C3A",
                 "LIQUID":"#5B94D0","PASTRY":"#C79B5E","OTHER":"#9A8F84"})[cat] || Theme.colors.ink3
    }
    function catLabel(cat) {
        return ({"VEGETABLE":I18n.t('shopping.categories.vegetables'),
                 "SPICE":I18n.t('shopping.categories.spices'),
                 "MEAT":I18n.t('shopping.categories.meat'),
                 "LIQUID":I18n.t('shopping.categories.liquid'),
                 "PASTRY":I18n.t('shopping.categories.pastry'),
                 "OTHER":I18n.t('shopping.categories.other')})[cat] || cat
    }
    function formatQty(quantity, unit) {
        var q = quantity
        if (unit === "GR")    return q >= 1000 ? (Math.round(q/100)/10 + " " + I18n.t('ingredients.units.KG'))    : (Math.round(q)       + " " + I18n.t('ingredients.units.GR'))
        if (unit === "ML")    return q >= 1000 ? (Math.round(q/100)/10 + " " + I18n.t('ingredients.units.L'))     : (Math.round(q)       + " " + I18n.t('ingredients.units.ML'))
        if (unit === "KG")    return (Math.round(q*10)/10) + " " + I18n.t('ingredients.units.KG')
        if (unit === "L")     return (Math.round(q*10)/10) + " " + I18n.t('ingredients.units.L')
        if (unit === "PIECE") return Math.round(q)         + " " + I18n.t('ingredients.units.PIECE')
        if (unit === "CAS")   return Math.round(q)         + " " + I18n.t('ingredients.units.CAS')
        if (unit === "CAC")   return Math.round(q)         + " " + I18n.t('ingredients.units.CAC')
        return Math.round(q) + " " + unit.toLowerCase()
    }

    // ── Fixed header ──────────────────────────────────────────────────────
    Column {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        topPadding:   Theme.sizes.lg
        leftPadding:  Theme.sizes.lg
        rightPadding: Theme.sizes.lg
        spacing:      0

        Text {
            text:           (I18n.currentLanguage, I18n.t('shopping.title'))
            font.pixelSize: 30
            font.family:    Theme.typography.fontSerif
            color:          Theme.colors.ink
        }

        // Progress bar
        Row {
            width:   parent.width - Theme.sizes.lg * 2
            height:  22
            spacing: 10
            visible: shoppingPage.totalCount > 0

            Rectangle {
                width:  parent.width - progressLbl.implicitWidth - 10
                height: 6; radius: 999; y: 8
                color:        Theme.colors.card
                border.color: "#141B1714"; border.width: 1
                clip: true

                Rectangle {
                    width:  parent.width * (shoppingPage.checkedCount / Math.max(shoppingPage.totalCount, 1))
                    height: parent.height
                    color:  Theme.colors.harissa.main
                    radius: 999
                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }

            Text {
                id: progressLbl
                anchors.verticalCenter: parent.verticalCenter
                text:               shoppingPage.checkedCount + "/" + shoppingPage.totalCount
                font.pixelSize:     11
                font.family:        Theme.typography.fontMono
                font.letterSpacing: 0.8
                color:              Theme.colors.ink2
            }
        }
    }

    // ── Scrollable list ───────────────────────────────────────────────────
    ScrollView {
        anchors {
            top:    pageHeader.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
            topMargin: Theme.sizes.md
        }
        contentWidth: availableWidth
        clip: true

        Column {
            width:         parent.width
            leftPadding:   Theme.sizes.lg
            rightPadding:  Theme.sizes.lg
            bottomPadding: 100
            spacing:       Theme.sizes.md

            // Empty state
            Item {
                width:  parent.width - Theme.sizes.lg * 2
                height: 60
                visible: shoppingPage.totalCount === 0

                Text {
                    anchors.centerIn: parent
                    text:           (I18n.currentLanguage, I18n.t('shopping.emptyHint'))
                    font.pixelSize: 13; font.family: Theme.typography.fontUI
                    color:          Theme.colors.ink3
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    width: parent.width
                }
            }

            // Category cards
            Repeater {
                model: shoppingPage._groups

                Rectangle {
                    id:     catCard
                    width:  parent.width - Theme.sizes.lg * 2
                    radius: 18
                    color:  Theme.colors.card

                    readonly property color dot: modelData.dotColor

                    height: catHdr.height + catItemsCol.implicitHeight + 16

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled:        true
                        shadowColor:          "#2E1B1714"
                        shadowVerticalOffset: 12
                        shadowBlur:           0.45
                    }

                    // Category header
                    Item {
                        id: catHdr
                        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 10; leftMargin: 10; rightMargin: 10 }
                        height: 28

                        Row {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                            spacing: 8

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: catCard.dot
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text:               (I18n.currentLanguage, (I18n.currentLanguage === 'ar') ? shoppingPage.catLabel(modelData.cat) : shoppingPage.catLabel(modelData.cat).toUpperCase())
                                font.pixelSize:     11
                                font.family:        Theme.typography.fontUI
                                font.weight:        Font.Bold
                                font.letterSpacing: (I18n.currentLanguage === 'ar') ? 0 : 1.2
                                color:              Theme.colors.ink
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                            text:           modelData.items.length
                            font.pixelSize: 11
                            font.family:    Theme.typography.fontMono
                            color:          Theme.colors.ink3
                        }
                    }

                    // Items
                    Column {
                        id: catItemsCol
                        anchors { top: catHdr.bottom; left: parent.left; right: parent.right }
                        spacing: 0

                        Repeater {
                            model: modelData.items

                            Item {
                                id:     itemRow
                                width:  parent.width
                                height: 44

                                Rectangle {
                                    visible: index > 0
                                    anchors { top: parent.top; left: parent.left; right: parent.right }
                                    height: 1; color: "#141B1714"
                                }

                                Row {
                                    anchors { fill: parent; leftMargin: 10; rightMargin: 10; topMargin: index > 0 ? 1 : 0 }
                                    spacing: 12

                                    // Checkbox 20×20 radius 6
                                    Rectangle {
                                        id:     chk
                                        width:  20; height: 20; radius: 6
                                        anchors.verticalCenter: parent.verticalCenter

                                        readonly property bool ticked: shoppingPage._checkedSet[modelData.ingredientId] || false

                                        color:        ticked ? catCard.dot : Theme.colors.card
                                        border.color: ticked ? catCard.dot : "#241B1714"
                                        border.width: 1

                                        Canvas {
                                            anchors.fill: parent
                                            visible: chk.ticked
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.clearRect(0, 0, width, height)
                                                ctx.strokeStyle = "#ffffff"
                                                ctx.lineWidth   = 2
                                                ctx.lineCap     = "round"
                                                ctx.lineJoin    = "round"
                                                ctx.beginPath()
                                                ctx.save()
                                                ctx.translate(4, 4)
                                                ctx.moveTo(2,   6.5)
                                                ctx.lineTo(4.8, 9)
                                                ctx.lineTo(10,  3)
                                                ctx.stroke()
                                                ctx.restore()
                                            }
                                            onVisibleChanged: if (visible) requestPaint()
                                            Component.onCompleted: requestPaint()
                                        }

                                        MouseArea {
                                            anchors.fill:    parent
                                            anchors.margins: -4
                                            onClicked: {
                                                var cs = Object.assign({}, shoppingPage._checkedSet)
                                                cs[modelData.ingredientId] = !cs[modelData.ingredientId]
                                                shoppingPage._checkedSet = cs
                                                shoppingListModel.toggleItemChecked(modelData.modelIndex)
                                            }
                                        }
                                    }

                                    // Name
                                    Text {
                                        width:           parent.width - 20 - 12 - qtyLbl.implicitWidth - 12
                                        text:            ((I18n.currentLanguage === 'ar') && modelData.nameAr) ? modelData.nameAr : (modelData.name || "")
                                        font.pixelSize:  14
                                        font.family:     ((I18n.currentLanguage === 'ar') && modelData.nameAr) ? "Tajawal" : Theme.typography.fontUI
                                        font.weight:     Font.Medium
                                        color:           chk.ticked ? Theme.colors.ink3 : Theme.colors.ink
                                        font.strikeout:  chk.ticked
                                        elide:           Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    // Quantity
                                    Text {
                                        id: qtyLbl
                                        text:               shoppingPage.formatQty(modelData.quantity, modelData.unit)
                                        font.pixelSize:     11
                                        font.family:        Theme.typography.fontMono
                                        font.letterSpacing: 0.4
                                        color:              Theme.colors.ink2
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Item { width: parent.width; height: 6 }
                    }
                }
            }
        }
    }
}
