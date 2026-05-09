import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: homePage
    color: Theme.colors.bone

    // ── Signals for dish selection ─────────────────────────────────────────
    signal selectDishForSlot(dayId: int, slotType: string)  // slotType: "starter", "main", "dessert"
    signal updateDayServings(dayId: int, newServings: int)

    // ── State pour la popup ingrédients ───────────────────────────────────
    property int    _infoDishId:    -1
    property string _infoDishName:  ""
    property string _infoDishNameAr:""

    // Regenerate shopping list when planning changes (servings update etc.)
    Connections {
        target: weeklyPlanningModel
        function onModelReset() { shoppingListModel.generateForCurrentWeek() }
    }

    // ── Popup ingrédients du plat ─────────────────────────────────────────
    Popup {
        id: dishInfoPopup
        parent: Overlay.overlay
        x:      0
        y:      parent ? parent.height - height : 0
        width:  parent ? parent.width : 390
        height: Math.min(parent ? parent.height * 0.65 : 480, 520)

        modal:       true
        dim:         true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            topLeftRadius:  28
            topRightRadius: 28
            color: Theme.colors.bone
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled:        true
                shadowColor:          "#591B1714"
                shadowVerticalOffset: -10
                shadowBlur:           0.5
            }
        }

        enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 220; easing.type: Easing.OutCubic } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 160; easing.type: Easing.InCubic } }

        property var _ingredients: []

        onOpened: {
            _ingredients = homePage._infoDishId > 0
                         ? dishModel.ingredientsOfDish(homePage._infoDishId)
                         : []
        }

        contentItem: Item {
            Column {
                id: infoHeader
                anchors { top: parent.top; left: parent.left; right: parent.right }
                topPadding: 14; leftPadding: 18; rightPadding: 18; spacing: 10

                // Drag handle
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 42; height: 5; radius: 999; color: "#241B1714"
                }

                // Titre plat + ×
                Item {
                    width: parent.width - 36
                    height: Math.max(infoDishName.implicitHeight, 32)

                    Text {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        text: "×"; font.pixelSize: 22; font.family: Theme.typography.fontUI
                        color: Theme.colors.ink2
                        MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: dishInfoPopup.close() }
                    }

                    Text {
                        id: infoDishName
                        anchors { left: parent.left; right: parent.right; rightMargin: 32; verticalCenter: parent.verticalCenter }
                        text: (I18n.currentLanguage, (I18n.currentLanguage === 'ar' && homePage._infoDishNameAr)
                               ? homePage._infoDishNameAr : homePage._infoDishName)
                        font.pixelSize:     22
                        font.family:        (I18n.currentLanguage === 'ar') ? "Aref Ruqaa" : Theme.typography.fontSerif
                        color:              Theme.colors.ink
                        elide:              Text.ElideRight
                        horizontalAlignment:(I18n.currentLanguage === 'ar') ? Text.AlignRight : Text.AlignLeft
                    }
                }

                // Label "ingrédients · N"
                Text {
                    text: (I18n.currentLanguage, I18n.t('dishes.ingredients') +
                           (dishInfoPopup._ingredients.length > 0 ? " · " + dishInfoPopup._ingredients.length : ""))
                    font.pixelSize:      11; font.family: Theme.typography.fontUI
                    font.weight:         Font.Bold
                    font.letterSpacing:  (I18n.currentLanguage === 'ar') ? 0 : 1.1
                    font.capitalization: Font.AllUppercase
                    color:               Theme.colors.ink3
                }
            }

            ScrollView {
                anchors { top: infoHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; topMargin: 6 }
                contentWidth: availableWidth; clip: true

                Column {
                    width: parent.width
                    leftPadding: 18; rightPadding: 18; bottomPadding: 24; spacing: 0

                    // Empty state
                    Item {
                        width: parent.width - 36; height: 52
                        visible: dishInfoPopup._ingredients.length === 0
                        Text {
                            anchors.centerIn: parent
                            text: (I18n.currentLanguage, I18n.t('dishes.noIngredient'))
                            font.pixelSize: 13; font.family: Theme.typography.fontUI
                            color: Theme.colors.ink3
                        }
                    }

                    Repeater {
                        model: dishInfoPopup._ingredients

                        Rectangle {
                            width: parent.width - 36; height: 44; radius: 12
                            color: Theme.colors.card; border.color: "#141B1714"; border.width: 1

                            Row {
                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                spacing: 10

                                Rectangle {
                                    width: 8; height: 8; radius: 4; color: "#6B9A50"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: parent.width - 8 - 10 - qtyInfo.implicitWidth - 10
                                    text:  (I18n.currentLanguage, (I18n.currentLanguage === 'ar' && modelData.nameAr)
                                            ? modelData.nameAr : (modelData.name || ""))
                                    font.pixelSize: 14
                                    font.family:    (I18n.currentLanguage === 'ar' && modelData.nameAr) ? "Tajawal" : Theme.typography.fontUI
                                    font.weight:    Font.Medium; color: Theme.colors.ink
                                    elide:          Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    id: qtyInfo
                                    visible: (modelData.quantity || 0) > 0
                                    text: (I18n.currentLanguage,
                                           (modelData.quantity || 0) + " " + I18n.t('ingredients.units.' + (modelData.unit || "GR")))
                                    font.pixelSize: 11; font.family: Theme.typography.fontMono
                                    font.letterSpacing: 0.4; color: Theme.colors.ink2
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Week summary chips ─────────────────────────────────────────────────
    FilterChips {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.sizes.lg
        }
        activeFilters: ['starter', 'main', 'dessert']
        showWeekRange: true

        onFilterChanged: function(filters) {
            // Convertit les ids minuscules en types DB majuscules ; vide = tout inclure
            var types = (filters.length === 0 || filters.length === 3)
                        ? []
                        : filters.map(function(f) { return f.toUpperCase() })
            shoppingListModel.setMealTypeFilter(types)
        }
    }

    // ── Scrollable day cards ───────────────────────────────────────────────
    ScrollView {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Theme.sizes.lg
        }
        contentWidth: availableWidth
        clip: true

        Column {
            width: parent.width
            padding: Theme.sizes.lg
            spacing: Theme.sizes.lg

            // 7 DayCards bound to WeeklyPlanningModel
            Repeater {
                model: weeklyPlanningModel

                DayCard {
                    required property string starterName
                    required property string starterNameAr
                    required property string starterTone
                    required property string mainName
                    required property string mainNameAr
                    required property string mainTone
                    required property int    starterDishId
                    required property int    mainDishId
                    required property string dessertName
                    required property string dessertNameAr
                    required property string dessertTone
                    required property int    dessertDishId
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - Theme.sizes.xxl

                    // Day label computed from dayId → reactive to language changes
                    readonly property var _dayKeys: ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']
                    dayLabel: (I18n.currentLanguage, I18n.t('home.' + _dayKeys[dayId]))
                    isToday: dayId === (new Date().getDay() + 6) % 7

                    meals: [
                        { type: "starter", name: starterName, nameAr: starterNameAr, dishId: starterDishId, tone: starterTone },
                        { type: "main",    name: mainName,    nameAr: mainNameAr,    dishId: mainDishId,    tone: mainTone    },
                        { type: "dessert", name: dessertName, nameAr: dessertNameAr, dishId: dessertDishId, tone: dessertTone }
                    ]

                    slotFilters: header.activeFilters

                    onServingsUpdated: function(newServings) {
                        weeklyPlanningModel.updateDayServings(dayId, newServings)
                    }

                    onSelectDish: function(slotType) {
                        homePage.selectDishForSlot(dayId, slotType)
                    }

                    onDishInfoRequested: function(dishId, dishName, dishNameAr) {
                        homePage._infoDishId     = dishId
                        homePage._infoDishName   = dishName
                        homePage._infoDishNameAr = dishNameAr
                        dishInfoPopup.open()
                    }
                }
            }
        }
    }
}
