import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: dishesPage
    color: Theme.colors.bone

    signal openDishEditor(var dish)

    // ── Filtered dish lists ────────────────────────────────────────────────
    property string searchText:    ""
    property var    activeFilters: []

    property var starterDishes: []
    property var mainDishes:    []
    property var dessertDishes: []

    function applyFilter(dishes) {
        var q = searchText.toLowerCase().trim()
        if (!q) return dishes
        return dishes.filter(function(d) {
            return (d.name   || "").toLowerCase().indexOf(q) !== -1 ||
                   (d.nameAr || "").toLowerCase().indexOf(q) !== -1
        })
    }

    function reloadDishes() {
        starterDishes = applyFilter(dishModel.dishesOfType("STARTER"))
        mainDishes    = applyFilter(dishModel.dishesOfType("MAIN"))
        dessertDishes = applyFilter(dishModel.dishesOfType("DESSERT"))
    }

    onSearchTextChanged: reloadDishes()

    Component.onCompleted: reloadDishes()

    Connections {
        target: dishModel
        function onModelReset()   { dishesPage.reloadDishes() }
        function onRowsInserted() { dishesPage.reloadDishes() }
        function onRowsRemoved()  { dishesPage.reloadDishes() }
        function onDataChanged()  { dishesPage.reloadDishes() }
    }

    function sectionVisible(typeId) {
        return activeFilters.length === 0 || activeFilters.indexOf(typeId) !== -1
    }

    // ── Header (non-scrollable) ───────────────────────────────────────────
    Column {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        topPadding:  Theme.sizes.lg
        leftPadding: Theme.sizes.lg; rightPadding: Theme.sizes.lg
        spacing: Theme.sizes.lg

        Column {
            width: parent.width - Theme.sizes.lg * 2
            spacing: 6

            Text {
                text:           (I18n.currentLanguage, I18n.t('dishes.title'))
                font.pixelSize: 30
                font.family:    Theme.typography.fontSerif
                color:          Theme.colors.ink
            }

            Text {
                text: {
                    I18n.currentLanguage  // reactive dependency
                    var total = starterDishes.length + mainDishes.length + dessertDishes.length
                    return total + " " + I18n.t('dishes.unit') +
                           " · 3 " + I18n.t('dishes.catLabel')
                }
                font.pixelSize:      11
                font.family:         Theme.typography.fontMono
                font.letterSpacing:  1.54
                font.capitalization: Font.AllUppercase
                color:               Theme.colors.ink3
            }
        }

        SearchBar {
            width: parent.width - Theme.sizes.lg * 2
            onSearchChanged: function(t) { dishesPage.searchText = t }
        }

        FilterChips {
            width:         parent.width - Theme.sizes.lg * 2
            activeFilters: dishesPage.activeFilters
            onFilterChanged: function(filters) { dishesPage.activeFilters = filters }
        }
    }

    // ── Scrollable dish sections ───────────────────────────────────────────
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
            spacing:       Theme.sizes.xl

            // ── Entrées ──────────────────────────────────────────────────
            Column {
                width:   parent.width - Theme.sizes.lg * 2
                spacing: Theme.sizes.md
                visible: dishesPage.sectionVisible('starter') && dishesPage.starterDishes.length > 0

                SectionHeader {
                    label:    (I18n.currentLanguage, I18n.t('dishes.categories.starter'))
                    count:    dishesPage.starterDishes.length
                    dotColor: "#6B9A50"
                }

                DishGrid {
                    id:    starterGrid
                    width: parent.width
                    dishes: dishesPage.starterDishes
                    fallbackTone: "olive"
                    onDishTapped: function(d) { dishEditorSheet.openEdit(d) }
                }
            }

            // ── Plats ────────────────────────────────────────────────────
            Column {
                width:   parent.width - Theme.sizes.lg * 2
                spacing: Theme.sizes.md
                visible: dishesPage.sectionVisible('main') && dishesPage.mainDishes.length > 0

                SectionHeader {
                    label:    (I18n.currentLanguage, I18n.t('dishes.categories.main'))
                    count:    dishesPage.mainDishes.length
                    dotColor: Theme.colors.harissa.main
                }

                DishGrid {
                    id:    mainGrid
                    width: parent.width
                    dishes: dishesPage.mainDishes
                    fallbackTone: "harissa"
                    onDishTapped: function(d) { dishEditorSheet.openEdit(d) }
                }
            }

            // ── Desserts ─────────────────────────────────────────────────
            Column {
                width:   parent.width - Theme.sizes.lg * 2
                spacing: Theme.sizes.md
                visible: dishesPage.sectionVisible('dessert') && dishesPage.dessertDishes.length > 0

                SectionHeader {
                    label:    (I18n.currentLanguage, I18n.t('dishes.categories.dessert'))
                    count:    dishesPage.dessertDishes.length
                    dotColor: "#D49585"
                }

                DishGrid {
                    id:    dessertGrid
                    width: parent.width
                    dishes: dishesPage.dessertDishes
                    fallbackTone: "rose"
                    onDishTapped: function(d) { dishEditorSheet.openEdit(d) }
                }
            }
        }
    }

    // ── Dish editor sheet ─────────────────────────────────────────────────
    DishEditorSheet {
        id: dishEditorSheet
        parent: Overlay.overlay

        onSaveRequested: function(nameFr, nameAr, type, tone, baseServings, ingredients) {
            var dishId
            if (editDish) {
                dishModel.updateDishQml(editDish.dishId, nameFr, nameAr, type, tone, baseServings)
                dishId = editDish.dishId
            } else {
                dishId = dishModel.addDishQml(nameFr, nameAr, type, tone, baseServings)
            }
            if (dishId > 0) dishModel.saveDishIngredients(dishId, ingredients)
        }

        onDeleteRequested: function(dishId) {
            dishModel.deleteDish(dishId)
        }
    }

    // ── FAB ───────────────────────────────────────────────────────────────
    Item {
        anchors {
            right:        parent.right
            bottom:       parent.bottom
            rightMargin:  22
            bottomMargin: 28
        }
        width: 58; height: 58
        z: 10

        Rectangle {
            anchors.fill: parent
            radius: 999
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#336FA8" }
                GradientStop { position: 1.0; color: "#264E85" }
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled:        true
                shadowColor:          "#661B1714"
                shadowVerticalOffset: 10
                shadowBlur:           0.5
            }

            Canvas {
                anchors.centerIn: parent
                width: 26; height: 26
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = "#ffffff"
                    ctx.lineWidth   = 2.4
                    ctx.lineCap     = "round"
                    ctx.beginPath(); ctx.moveTo(13, 5);  ctx.lineTo(13, 21); ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(5, 13);  ctx.lineTo(21, 13); ctx.stroke()
                }
                Component.onCompleted: requestPaint()
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: dishEditorSheet.openNew()
        }
    }

    // ── Inline sub-components ─────────────────────────────────────────────

    component SectionHeader: Item {
        property string label:    ""
        property int    count:    0
        property color  dotColor: Theme.colors.ink3

        width: parent ? parent.width : 0
        height: 24

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Rectangle {
                width: 8; height: 8; radius: 4
                color: dotColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text:           label
                font.pixelSize: 14
                font.family:    Theme.typography.fontUI
                font.weight:    Font.Bold
                color:          Theme.colors.ink
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text:           "· " + count
                font.pixelSize: 13
                font.family:    Theme.typography.fontUI
                color:          Theme.colors.ink3
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    component DishGrid: Item {
        id:   dishGridRoot
        property var    dishes:       []
        property string fallbackTone: "harissa"
        signal dishTapped(var dish)

        implicitHeight: gridFlow.implicitHeight

        Flow {
            id:      gridFlow
            width:   parent.width
            spacing: 10

            Repeater {
                model: dishGridRoot.dishes

                Rectangle {
                    width:  (gridFlow.width - 10) / 2
                    height: 72
                    radius: 14
                    color:        Theme.colors.card
                    border.color: "#141B1714"
                    border.width: 1
                    clip:         true

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled:        true
                        shadowColor:          "#121B1714"
                        shadowVerticalOffset: 2
                        shadowBlur:           0.35
                    }

                    Row {
                        anchors { fill: parent; leftMargin: 10; topMargin: 10; bottomMargin: 10 }
                        spacing: 10

                        DishThumb {
                            size:   48
                            radius: 11
                            label:  {
                                var n = ((I18n.currentLanguage === 'ar') && modelData.nameAr) ? modelData.nameAr : (modelData.name || "")
                                return (I18n.currentLanguage === 'ar') ? n.substring(0, 4) : n.substring(0, 5).toUpperCase()
                            }
                            tone:   modelData.tone || dishGridRoot.fallbackTone
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - 48 - 10 - 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Text {
                                width:          parent.width
                                text:           ((I18n.currentLanguage === 'ar') && modelData.nameAr) ? modelData.nameAr : (modelData.name || "")
                                font.pixelSize: 14
                                font.family:    Theme.typography.fontUI
                                font.weight:    Font.DemiBold
                                color:          Theme.colors.ink
                                elide:          Text.ElideRight
                            }

                            Text {
                                visible:        (modelData.ingredientCount || 0) > 0
                                text:           (I18n.currentLanguage, "≈ " + (modelData.ingredientCount || 0) + " " + I18n.t('dishes.ingr'))
                                font.pixelSize: 11
                                font.family:    Theme.typography.fontUI
                                color:          Theme.colors.ink3
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked:    dishGridRoot.dishTapped(modelData)
                    }
                }
            }
        }
    }
}
