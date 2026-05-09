import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Popup {
    id: root

    // ── Public API ────────────────────────────────────────────────────────
    signal confirmed(var ingredients)   // [{ingredientId, name, unit, quantity: 0}]
    signal manageBaseRequested()

    function openPicker(existingIds) {
        _selectedIds    = existingIds ? existingIds.slice() : []
        _search         = ""
        _catFilter      = "ALL"
        _allIngredients = ingredientModel.allAsVariantList()
        open()
    }

    Connections {
        target: ingredientModel
        function onModelReset() {
            if (root.visible) root._allIngredients = ingredientModel.allAsVariantList()
        }
    }

    // ── Internal state ────────────────────────────────────────────────────
    property string _search:          ""
    property string _catFilter:       "ALL"
    property var    _selectedIds:     []
    property var    _allIngredients:  []

    readonly property var _filteredIngredients: {
        var q = _search.toLowerCase().trim()
        return _allIngredients.filter(function(i) {
            var matchCat = (_catFilter === "ALL" || i.category === _catFilter)
            var matchQ   = !q
                        || (i.name   || "").toLowerCase().indexOf(q) !== -1
                        || (i.nameAr || "").indexOf(q) !== -1
            return matchCat && matchQ
        })
    }

    // Flat list: section headers + ingredient items, no selected state (handled per-delegate)
    readonly property var _flatList: {
        var result = []
        var filtered = _filteredIngredients
        var currentCat = null
        for (var i = 0; i < filtered.length; i++) {
            var ing = filtered[i]
            if (ing.category !== currentCat) {
                currentCat = ing.category
                var cnt = 0
                for (var j = i; j < filtered.length && filtered[j].category === currentCat; j++) cnt++
                result.push({ isHeader: true,  cat: currentCat, count: cnt })
            }
            result.push({ isHeader: false, ing: ing })
        }
        return result
    }

    readonly property var _catMeta: ({
        "VEGETABLE": { dot: "#6B9A50" },
        "SPICE":     { dot: "#E0C660" },
        "MEAT":      { dot: "#E75C3A" },
        "LIQUID":    { dot: "#5B94D0" },
        "PASTRY":    { dot: "#C79B5E" },
        "OTHER":     { dot: "#9A8F84" }
    })

    readonly property var _filterChips: (I18n.currentLanguage, [
        { id: "ALL",       label: I18n.t('ingredients.all')                },
        { id: "VEGETABLE", label: I18n.t('shopping.categories.vegetables') },
        { id: "SPICE",     label: I18n.t('shopping.categories.spices')     },
        { id: "MEAT",      label: I18n.t('shopping.categories.meat')       },
        { id: "LIQUID",    label: I18n.t('shopping.categories.liquid')     },
        { id: "PASTRY",    label: I18n.t('shopping.categories.pastry')     },
        { id: "OTHER",     label: I18n.t('shopping.categories.other')      }
    ])

    // ── Popup geometry ────────────────────────────────────────────────────
    x:     0
    y:     parent ? parent.height - height : 0
    width: parent ? parent.width : 390
    height: Math.max(640, parent ? parent.height * 0.92 : 640)

    modal:       true
    dim:         true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 160; easing.type: Easing.InCubic }
    }

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

    function catLabel(cat) {
        var map = {
            "VEGETABLE": I18n.t('shopping.categories.vegetables'),
            "SPICE":     I18n.t('shopping.categories.spices'),
            "MEAT":      I18n.t('shopping.categories.meat'),
            "LIQUID":    I18n.t('shopping.categories.liquid'),
            "PASTRY":    I18n.t('shopping.categories.pastry'),
            "OTHER":     I18n.t('shopping.categories.other')
        }
        return map[cat] || cat
    }

    // ── Content ────────────────────────────────────────────────────────────
    contentItem: Item {

        // ── Fixed header ──────────────────────────────────────────────────
        Column {
            id: headerArea
            anchors { top: parent.top; left: parent.left; right: parent.right }
            topPadding:   14
            leftPadding:  18
            rightPadding: 18
            spacing:      10

            // Drag handle
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 42; height: 5; radius: 999
                color: "#241B1714"
            }

            // Title row: serif title + "Gérer la base" pill + × close
            Item {
                width:  parent.width - 36
                height: Math.max(titleText.implicitHeight, rightActions.height)

                Text {
                    id: titleText
                    anchors {
                        left:           parent.left
                        right:          rightActions.left
                        rightMargin:    8
                        verticalCenter: parent.verticalCenter
                    }
                    text:           (I18n.currentLanguage, I18n.t('ingredients.pickTitle'))
                    font.pixelSize: 22
                    font.family:    Theme.typography.fontSerif
                    color:          Theme.colors.ink
                    elide:          Text.ElideRight
                }

                Row {
                    id: rightActions
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: 6

                    Rectangle {
                        height: 28
                        width:  dbRow.implicitWidth + 20
                        radius: 999
                        color:        Theme.colors.card
                        border.color: "#241B1714"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Row {
                            id: dbRow
                            anchors.centerIn: parent
                            spacing: 4

                            Image {
                                width:  11; height: 11
                                source: "qrc:/icons/database.svg"
                                sourceSize: Qt.size(22, 22)
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization:      1.0
                                    colorizationColor: Theme.colors.ink2
                                }
                            }

                            Text {
                                text:           (I18n.currentLanguage, I18n.t('ingredients.manageBase'))
                                font.pixelSize: 11
                                font.family:    Theme.typography.fontUI
                                font.weight:    Font.Bold
                                color:          Theme.colors.ink2
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked:    root.manageBaseRequested()
                        }
                    }

                    Item {
                        width: 28; height: 28
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text:           "×"
                            font.pixelSize: 22
                            font.family:    Theme.typography.fontUI
                            color:          Theme.colors.ink2
                        }

                        MouseArea {
                            anchors.fill:   parent
                            anchors.margins: -4
                            onClicked:      root.close()
                        }
                    }
                }
            }

            // Search bar
            SearchBar {
                width:       parent.width - 36
                placeholder: (I18n.currentLanguage, I18n.t('ingredients.search'))
                onSearchChanged: function(t) { root._search = t }
            }

            // Filter chips (horizontal scroll)
            Flickable {
                width:         parent.width - 36
                height:        30
                contentWidth:  chipsRow.implicitWidth
                contentHeight: 30
                clip:          true

                Row {
                    id:      chipsRow
                    spacing: 6

                    Repeater {
                        model: root._filterChips

                        Rectangle {
                            height: 28
                            width:  chipLbl.implicitWidth + 22
                            radius: 999

                            readonly property bool sel: root._catFilter === modelData.id

                            color:        sel ? Theme.colors.ink  : Theme.colors.card
                            border.color: sel ? Theme.colors.ink  : "#241B1714"
                            border.width: 1

                            Text {
                                id: chipLbl
                                anchors.centerIn: parent
                                text:           modelData.label
                                font.pixelSize: 11
                                font.family:    Theme.typography.fontUI
                                font.weight:    Font.Bold
                                color:          sel ? "#ffffff" : Theme.colors.ink2
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked:    root._catFilter = modelData.id
                            }
                        }
                    }
                }
            }
        }

        // ── Scrollable ingredient list ─────────────────────────────────────
        ScrollView {
            anchors {
                top:    headerArea.bottom
                left:   parent.left
                right:  parent.right
                bottom: footerArea.top
                topMargin: 6
            }
            contentWidth: availableWidth
            clip:         true

            Column {
                width:         parent.width
                bottomPadding: 8
                spacing:       0

                Repeater {
                    model: root._flatList

                    Item {
                        width:  parent.width
                        height: modelData.isHeader ? 32 : 50

                        // ── Section header ────────────────────────────────
                        Row {
                            visible: modelData.isHeader
                            anchors {
                                left:           parent.left
                                leftMargin:     18
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: 6

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: modelData.isHeader
                                       ? (root._catMeta[modelData.cat]
                                          ? root._catMeta[modelData.cat].dot : Theme.colors.ink3)
                                       : "transparent"
                            }

                            Text {
                                text: (I18n.currentLanguage, modelData.isHeader ? ((I18n.currentLanguage === 'ar') ? catLabel(modelData.cat) : catLabel(modelData.cat).toUpperCase()) : "")
                                font.pixelSize:      10
                                font.family:         Theme.typography.fontUI
                                font.weight:         Font.Bold
                                font.letterSpacing:  1.0
                                color:               Theme.colors.ink2
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text:           modelData.isHeader ? ("· " + modelData.count) : ""
                                font.pixelSize: 10
                                font.family:    Theme.typography.fontUI
                                color:          Theme.colors.ink3
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // ── Ingredient card ───────────────────────────────
                        Rectangle {
                            id:      ingCard
                            visible: !modelData.isHeader
                            anchors {
                                left:           parent.left
                                right:          parent.right
                                leftMargin:     18
                                rightMargin:    18
                                verticalCenter: parent.verticalCenter
                            }
                            height: 44
                            radius: 12
                            color:  Theme.colors.card
                            border.color: "#141B1714"
                            border.width: 1

                            readonly property bool isSelected:
                                !modelData.isHeader && modelData.ing !== undefined &&
                                root._selectedIds.indexOf(modelData.ing.ingredientId) !== -1

                            Row {
                                anchors {
                                    fill:         parent
                                    leftMargin:   12
                                    rightMargin:  12
                                }
                                spacing: 10

                                Text {
                                    width:          parent.width - 22 - 10
                                    text:           (!modelData.isHeader && modelData.ing) ? (((I18n.currentLanguage === 'ar') && modelData.ing.nameAr) ? modelData.ing.nameAr : (modelData.ing.name || "")) : ""
                                    font.pixelSize: 14
                                    font.family:    ((I18n.currentLanguage === 'ar') && modelData.ing && modelData.ing.nameAr) ? "Tajawal" : Theme.typography.fontUI
                                    font.weight:    Font.Medium
                                    color:          Theme.colors.ink
                                    elide:          Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width:  22; height: 22; radius: 999
                                    anchors.verticalCenter: parent.verticalCenter
                                    color:        ingCard.isSelected ? Theme.colors.harissa.main : Theme.colors.card
                                    border.color: ingCard.isSelected ? Theme.colors.harissa.main : "#241B1714"
                                    border.width: ingCard.isSelected ? 0 : 1

                                    Text {
                                        anchors.centerIn: parent
                                        visible:        ingCard.isSelected
                                        text:           "✓"
                                        font.pixelSize: 11
                                        font.weight:    Font.Bold
                                        color:          "#ffffff"
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled:      !modelData.isHeader && modelData.ing !== undefined
                                onClicked: {
                                    var ingId = modelData.ing.ingredientId
                                    var arr   = root._selectedIds.slice()
                                    var pos   = arr.indexOf(ingId)
                                    if (pos !== -1) arr.splice(pos, 1)
                                    else            arr.push(ingId)
                                    root._selectedIds = arr
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Footer ────────────────────────────────────────────────────────
        Item {
            id: footerArea
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 92

            Rectangle {
                anchors {
                    left: parent.left; right: parent.right; bottom: parent.bottom
                    leftMargin: 18; rightMargin: 18; bottomMargin: 24
                }
                height: 52
                radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.colors.harissa.main }
                    GradientStop { position: 1.0; color: Theme.colors.harissa.deep }
                }
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled:        true
                    shadowColor:          "#8CE75C3A"
                    shadowVerticalOffset: 8
                    shadowBlur:           0.4
                }

                Text {
                    anchors.centerIn: parent
                    text:           (I18n.currentLanguage, I18n.t('ingredients.done'))
                    font.pixelSize: 14
                    font.family:    Theme.typography.fontUI
                    font.weight:    Font.Bold
                    color:          "#ffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var result = []
                        for (var i = 0; i < root._allIngredients.length; i++) {
                            var ing = root._allIngredients[i]
                            if (root._selectedIds.indexOf(ing.ingredientId) !== -1)
                                result.push({ ingredientId: ing.ingredientId,
                                              name: ing.name, unit: ing.unit, quantity: 0 })
                        }
                        root.confirmed(result)
                        root.close()
                    }
                }
            }
        }
    }
}
