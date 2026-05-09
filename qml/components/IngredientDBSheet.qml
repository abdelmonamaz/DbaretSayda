import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Popup {
    id: root

    // ── Popup geometry (same as IngredientPickerSheet) ─────────────────────
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

    // ── Internal state ────────────────────────────────────────────────────
    property var    _allIngredients:   []
    property int    _confirmDeleteId:  -1

    property bool   _addingNew:  false
    property string _newNameFr:  ""
    property string _newNameAr:  ""
    property string _newCat:     "VEGETABLE"
    property string _newUnit:    "GR"

    // Édition inline
    property int    _editingId:    -1
    property string _editNameFr:   ""
    property string _editNameAr:   ""
    property string _editCat:      "VEGETABLE"
    property string _editUnit:     "GR"

    readonly property bool _canAdd:    _newNameFr.trim().length > 0
    readonly property bool _canUpdate: _editNameFr.trim().length > 0

    readonly property var _flatList: {
        var result = []
        var all = _allIngredients
        var currentCat = null
        for (var i = 0; i < all.length; i++) {
            var ing = all[i]
            if (ing.category !== currentCat) {
                currentCat = ing.category
                var cnt = 0
                for (var j = i; j < all.length && all[j].category === currentCat; j++) cnt++
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

    readonly property var _cats: (I18n.currentLanguage, [
        { id: "VEGETABLE", label: I18n.t('shopping.categories.vegetables'), dot: "#6B9A50" },
        { id: "SPICE",     label: I18n.t('shopping.categories.spices'),     dot: "#E0C660" },
        { id: "MEAT",      label: I18n.t('shopping.categories.meat'),       dot: "#E75C3A" },
        { id: "LIQUID",    label: I18n.t('shopping.categories.liquid'),     dot: "#5B94D0" },
        { id: "PASTRY",    label: I18n.t('shopping.categories.pastry'),     dot: "#C79B5E" },
        { id: "OTHER",     label: I18n.t('shopping.categories.other'),      dot: "#9A8F84" }
    ])

    readonly property var _units: (I18n.currentLanguage, [
        { id: "GR",    label: I18n.t('ingredients.units.GR')    },
        { id: "KG",    label: I18n.t('ingredients.units.KG')    },
        { id: "ML",    label: I18n.t('ingredients.units.ML')    },
        { id: "L",     label: I18n.t('ingredients.units.L')     },
        { id: "PIECE", label: I18n.t('ingredients.units.PIECE') },
        { id: "CAS",   label: I18n.t('ingredients.units.CAS')   },
        { id: "CAC",   label: I18n.t('ingredients.units.CAC')   }
    ])

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

    onOpened: {
        _allIngredients  = ingredientModel.allAsVariantList()
        _addingNew       = false
        _editingId       = -1
        _confirmDeleteId = -1
    }

    Connections {
        target: ingredientModel
        function onModelReset() {
            if (root.visible) root._allIngredients = ingredientModel.allAsVariantList()
        }
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
            spacing:      12

            // Drag handle
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 42; height: 5; radius: 999
                color: "#241B1714"
            }

            // Title row
            Item {
                width:  parent.width - 36
                height: titleText.implicitHeight + 4

                Text {
                    id: titleText
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    text:           (I18n.currentLanguage, I18n.t('ingredients.dbTitle'))
                    font.pixelSize: 22
                    font.family:    Theme.typography.fontSerif
                    color:          Theme.colors.ink
                }

                Item {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    width: 28; height: 28

                    Text {
                        anchors.centerIn: parent
                        text:           "×"
                        font.pixelSize: 22
                        font.family:    Theme.typography.fontUI
                        color:          Theme.colors.ink2
                    }
                    MouseArea {
                        anchors.fill:    parent
                        anchors.margins: -4
                        onClicked:       root.close()
                    }
                }
            }

            // ── "+ Nouvel ingrédient" button (masqué si form actif) ───────
            Column {
                width:   parent.width - 36
                spacing: 10
                visible: !root._addingNew && root._editingId < 0

                Rectangle {
                    width:  parent.width
                    height: 46
                    radius: 12
                    color:        "transparent"
                    border.color: Theme.colors.harissa.main
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text:           (I18n.currentLanguage, I18n.t('ingredients.newIngredient'))
                        font.pixelSize: 13
                        font.family:    Theme.typography.fontUI
                        font.weight:    Font.Bold
                        color:          Theme.colors.harissa.deep
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root._newNameFr = ""; root._newNameAr = ""
                            root._newCat = "VEGETABLE"; root._newUnit = "GR"
                            root._addingNew = true
                        }
                    }
                }
            }

            // ── Edit ingredient form (visible when _editingId >= 0) ───────
            Column {
                width:   parent.width - 36
                spacing: 8
                visible: root._editingId >= 0

                // Titre
                Text {
                    text:           (I18n.currentLanguage, I18n.t('ingredients.editTitle'))
                    font.pixelSize: 13; font.family: Theme.typography.fontUI
                    font.weight:    Font.Bold
                    font.letterSpacing: (I18n.currentLanguage === 'ar') ? 0 : 0.8
                    color:          Theme.colors.ink2
                }

                // FR name
                Rectangle {
                    width: parent.width; height: 46
                    radius: 12; color: Theme.colors.card
                    border.color: "#241B1714"; border.width: 1
                    Item {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12; topMargin: 10; bottomMargin: 10 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: editFrInput.text.length === 0
                            text:    (I18n.currentLanguage, I18n.t('dishes.nameFr'))
                            font.pixelSize: 15; font.family: Theme.typography.fontUI
                            color:   Theme.colors.ink3
                        }
                        TextInput {
                            id: editFrInput
                            anchors.fill:      parent
                            text:              root._editNameFr
                            font.pixelSize:    15; font.family: Theme.typography.fontSerif
                            color:             Theme.colors.ink
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse:     true; clip: true
                            onTextEdited:      root._editNameFr = text
                            KeyNavigation.tab: editArInput
                        }
                    }
                }

                // AR name
                Rectangle {
                    width: parent.width; height: 46
                    radius: 12; color: Theme.colors.card
                    border.color: "#241B1714"; border.width: 1
                    Item {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12; topMargin: 10; bottomMargin: 10 }
                        Text {
                            anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                            visible: editArInput.text.length === 0
                            text:    (I18n.currentLanguage, I18n.t('dishes.nameAr'))
                            font.pixelSize: 15; font.family: "Tajawal"
                            color:   Theme.colors.ink3
                        }
                        TextInput {
                            id: editArInput
                            anchors.fill:          parent
                            text:                  root._editNameAr
                            font.pixelSize:        15; font.family: "Tajawal"
                            color:                 Theme.colors.ink
                            horizontalAlignment:   TextInput.AlignRight
                            verticalAlignment:     TextInput.AlignVCenter
                            selectByMouse:         true; clip: true
                            onTextEdited:          root._editNameAr = text
                            KeyNavigation.backtab: editFrInput
                        }
                    }
                }

                // Category chips
                Flickable {
                    width: parent.width; height: 30
                    contentWidth: editCatRow.implicitWidth; contentHeight: 30; clip: true
                    Row {
                        id: editCatRow; spacing: 6
                        Repeater {
                            model: root._cats
                            Rectangle {
                                height: 28; width: editCatLbl.implicitWidth + 22; radius: 999
                                readonly property bool sel: root._editCat === modelData.id
                                color:        sel ? modelData.dot : Theme.colors.card
                                border.color: sel ? modelData.dot : "#241B1714"; border.width: 1
                                Text { id: editCatLbl; anchors.centerIn: parent; text: modelData.label; font.pixelSize: 11; font.family: Theme.typography.fontUI; font.weight: Font.Bold; color: sel ? "#ffffff" : Theme.colors.ink2 }
                                MouseArea { anchors.fill: parent; onClicked: root._editCat = modelData.id }
                            }
                        }
                    }
                }

                // Unit chips
                Row {
                    spacing: 6
                    Repeater {
                        model: root._units
                        Rectangle {
                            height: 28; width: editUnitLbl.implicitWidth + 18; radius: 999
                            readonly property bool sel: root._editUnit === modelData.id
                            color:        sel ? Theme.colors.ink : Theme.colors.card
                            border.color: sel ? Theme.colors.ink : "#241B1714"; border.width: 1
                            Text { id: editUnitLbl; anchors.centerIn: parent; text: modelData.label; font.pixelSize: 11; font.family: Theme.typography.fontMono; font.weight: Font.Bold; color: sel ? "#ffffff" : Theme.colors.ink2 }
                            MouseArea { anchors.fill: parent; onClicked: root._editUnit = modelData.id }
                        }
                    }
                }

                // Annuler / Sauvegarder
                Row {
                    width: parent.width; spacing: 8
                    Rectangle {
                        width: (parent.width - 8) * 0.4; height: 44; radius: 12
                        color: Theme.colors.card; border.color: "#241B1714"; border.width: 1
                        Text { anchors.centerIn: parent; text: (I18n.currentLanguage, I18n.t('button.cancel')); font.pixelSize: 13; font.family: Theme.typography.fontUI; font.weight: Font.DemiBold; color: Theme.colors.ink }
                        MouseArea { anchors.fill: parent; onClicked: root._editingId = -1 }
                    }
                    Rectangle {
                        width: (parent.width - 8) * 0.6; height: 44; radius: 12
                        color: root._canUpdate ? Theme.colors.harissa.main : "#241B1714"
                        Text { anchors.centerIn: parent; text: (I18n.currentLanguage, I18n.t('button.save')); font.pixelSize: 13; font.family: Theme.typography.fontUI; font.weight: Font.Bold; color: "#ffffff" }
                        MouseArea {
                            anchors.fill: parent; enabled: root._canUpdate
                            onClicked: {
                                ingredientModel.updateIngredient(
                                    root._editingId, root._editNameFr.trim(), root._editNameAr.trim(),
                                    root._editCat, root._editUnit)
                                root._editingId = -1
                            }
                        }
                    }
                }
            }

            // ── New ingredient form (visible when _addingNew) ─────────────
            Column {
                width:   parent.width - 36
                spacing: 8
                visible: root._addingNew

                // FR name
                Rectangle {
                    width: parent.width; height: 46
                    radius: 12
                    color: Theme.colors.card
                    border.color: "#241B1714"; border.width: 1

                    Item {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12; topMargin: 10; bottomMargin: 10 }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: newFrInput.text.length === 0
                            text:    (I18n.currentLanguage, I18n.t('dishes.nameFr'))
                            font.pixelSize: 15; font.family: Theme.typography.fontUI
                            color:   Theme.colors.ink3
                        }
                        TextInput {
                            id: newFrInput
                            anchors.fill:      parent
                            font.pixelSize:    15
                            font.family:       Theme.typography.fontSerif
                            color:             Theme.colors.ink
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse:     true
                            clip:              true
                            onTextEdited:      root._newNameFr = text
                            KeyNavigation.tab: newArInput
                        }
                    }
                }

                // AR name
                Rectangle {
                    width: parent.width; height: 46
                    radius: 12
                    color: Theme.colors.card
                    border.color: "#241B1714"; border.width: 1

                    Item {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12; topMargin: 10; bottomMargin: 10 }

                        Text {
                            anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                            visible: newArInput.text.length === 0
                            text:    (I18n.currentLanguage, I18n.t('dishes.nameAr'))
                            font.pixelSize: 15; font.family: "Tajawal"
                            color:   Theme.colors.ink3
                        }
                        TextInput {
                            id: newArInput
                            anchors.fill:          parent
                            font.pixelSize:        15
                            font.family:           "Tajawal"
                            color:                 Theme.colors.ink
                            horizontalAlignment:   TextInput.AlignRight
                            verticalAlignment:     TextInput.AlignVCenter
                            selectByMouse:         true
                            clip:                  true
                            onTextEdited:          root._newNameAr = text
                            KeyNavigation.backtab: newFrInput
                        }
                    }
                }

                // Category chips
                Flickable {
                    width: parent.width; height: 30
                    contentWidth: catChipsRow.implicitWidth
                    contentHeight: 30; clip: true

                    Row {
                        id: catChipsRow
                        spacing: 6

                        Repeater {
                            model: root._cats

                            Rectangle {
                                height: 28
                                width:  catLbl.implicitWidth + 22
                                radius: 999
                                readonly property bool sel: root._newCat === modelData.id
                                color:        sel ? modelData.dot : Theme.colors.card
                                border.color: sel ? modelData.dot : "#241B1714"
                                border.width: 1

                                Text {
                                    id: catLbl
                                    anchors.centerIn: parent
                                    text:           modelData.label
                                    font.pixelSize: 11
                                    font.family:    Theme.typography.fontUI
                                    font.weight:    Font.Bold
                                    color:          sel ? "#ffffff" : Theme.colors.ink2
                                }
                                MouseArea { anchors.fill: parent; onClicked: root._newCat = modelData.id }
                            }
                        }
                    }
                }

                // Unit chips
                Row {
                    spacing: 6

                    Repeater {
                        model: root._units

                        Rectangle {
                            height: 28
                            width:  unitLbl.implicitWidth + 18
                            radius: 999
                            readonly property bool sel: root._newUnit === modelData.id
                            color:        sel ? Theme.colors.ink : Theme.colors.card
                            border.color: sel ? Theme.colors.ink : "#241B1714"
                            border.width: 1

                            Text {
                                id: unitLbl
                                anchors.centerIn: parent
                                text:           modelData.label
                                font.pixelSize: 11
                                font.family:    Theme.typography.fontMono
                                font.weight:    Font.Bold
                                color:          sel ? "#ffffff" : Theme.colors.ink2
                            }
                            MouseArea { anchors.fill: parent; onClicked: root._newUnit = modelData.id }
                        }
                    }
                }

                // Annuler / Ajouter buttons
                Row {
                    width: parent.width
                    spacing: 8

                    Rectangle {
                        width:  (parent.width - 8) * 0.4
                        height: 44; radius: 12
                        color: Theme.colors.card
                        border.color: "#241B1714"; border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text:           (I18n.currentLanguage, I18n.t('button.cancel'))
                            font.pixelSize: 13; font.family: Theme.typography.fontUI
                            font.weight:    Font.DemiBold; color: Theme.colors.ink
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { root._addingNew = false }
                        }
                    }

                    Rectangle {
                        width:  (parent.width - 8) * 0.6
                        height: 44; radius: 12
                        color: root._canAdd ? Theme.colors.harissa.main : "#241B1714"

                        Text {
                            anchors.centerIn: parent
                            text:           (I18n.currentLanguage, I18n.t('button.add'))
                            font.pixelSize: 13; font.family: Theme.typography.fontUI
                            font.weight:    Font.Bold; color: "#ffffff"
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled:      root._canAdd
                            onClicked: {
                                ingredientModel.addIngredient(
                                    root._newNameFr.trim(), root._newNameAr.trim(),
                                    root._newCat, root._newUnit)
                                root._addingNew = false
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
                bottom: parent.bottom
                topMargin: 8
            }
            contentWidth: availableWidth
            clip:         true

            Column {
                width:         parent.width
                bottomPadding: 24
                spacing:       0

                Repeater {
                    model: root._flatList

                    Item {
                        width:  parent.width
                        height: modelData.isHeader ? 32 : 50

                        // ── Section header ────────────────────────────────
                        Row {
                            visible: modelData.isHeader
                            anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
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
                                text:               (I18n.currentLanguage, modelData.isHeader ? ((I18n.currentLanguage === 'ar') ? catLabel(modelData.cat) : catLabel(modelData.cat).toUpperCase()) : "")
                                font.pixelSize:     10; font.family: Theme.typography.fontUI
                                font.weight:        Font.Bold; font.letterSpacing: 1.0
                                color:              Theme.colors.ink2
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text:           modelData.isHeader ? ("· " + modelData.count) : ""
                                font.pixelSize: 10; font.family: Theme.typography.fontUI
                                color:          Theme.colors.ink3
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // ── Ingredient card ───────────────────────────────
                        Rectangle {
                            id: ingDbCard
                            visible: !modelData.isHeader
                            anchors {
                                left: parent.left; right: parent.right
                                leftMargin: 18; rightMargin: 18
                                verticalCenter: parent.verticalCenter
                            }
                            height: 44; radius: 12
                            color:  Theme.colors.card
                            border.color: "#141B1714"; border.width: 1

                            readonly property bool confirming:
                                !modelData.isHeader && modelData.ing !== undefined &&
                                root._confirmDeleteId === modelData.ing.ingredientId

                            Row {
                                anchors { fill: parent; leftMargin: 12; rightMargin: 10 }
                                spacing: 8

                                Text {
                                    width:          parent.width - (ingDbCard.confirming ? 108 : 36)
                                    text:           (!modelData.isHeader && modelData.ing) ? (((I18n.currentLanguage === 'ar') && modelData.ing.nameAr) ? modelData.ing.nameAr : (modelData.ing.name || "")) : ""
                                    font.pixelSize: 14; font.family: ((I18n.currentLanguage === 'ar') && modelData.ing && modelData.ing.nameAr) ? "Tajawal" : Theme.typography.fontUI
                                    font.weight:    Font.Medium; color: Theme.colors.ink
                                    elide:          Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Default: trash button
                                Rectangle {
                                    visible: !ingDbCard.confirming
                                    width: 30; height: 30; radius: 999
                                    color: Theme.colors.bone2
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        anchors.centerIn: parent
                                        width:  14; height: 14
                                        source: "qrc:/icons/trash.svg"
                                        sourceSize: Qt.size(28, 28)
                                        fillMode: Image.PreserveAspectFit
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            colorization:      1.0
                                            colorizationColor: Theme.colors.ink2
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: !modelData.isHeader && modelData.ing !== undefined
                                        onClicked: {
                                            root._confirmDeleteId = modelData.ing.ingredientId
                                        }
                                    }
                                }

                                // Confirm: "Non" + "Supprimer"
                                Row {
                                    visible: ingDbCard.confirming
                                    spacing: 6
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: nonLbl.implicitWidth + 14; height: 26; radius: 999
                                        color: Theme.colors.card
                                        border.color: "#241B1714"; border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: nonLbl
                                            anchors.centerIn: parent
                                            text:           (I18n.currentLanguage, I18n.t('button.no'))
                                            font.pixelSize: 10; font.family: Theme.typography.fontUI
                                            font.weight:    Font.DemiBold; color: Theme.colors.ink2
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked:    root._confirmDeleteId = -1
                                        }
                                    }

                                    Rectangle {
                                        width: delLbl.implicitWidth + 14; height: 26; radius: 999
                                        color: Theme.colors.harissa.main
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: delLbl
                                            anchors.centerIn: parent
                                            text:           (I18n.currentLanguage, I18n.t('button.delete'))
                                            font.pixelSize: 10; font.family: Theme.typography.fontUI
                                            font.weight:    Font.Bold; color: "#ffffff"
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            enabled: !modelData.isHeader && modelData.ing !== undefined
                                            onClicked: {
                                                var ingId = modelData.ing.ingredientId
                                                root._confirmDeleteId = -1
                                                ingredientModel.deleteIngredient(ingId)
                                            }
                                        }
                                    }
                                }
                            }
                            // Tap gauche → ouvre l'édition inline (hors mode confirmation)
                            MouseArea {
                                anchors {
                                    left: parent.left; top: parent.top; bottom: parent.bottom
                                    right: parent.right; rightMargin: 44
                                }
                                enabled: !modelData.isHeader && modelData.ing !== undefined && !ingDbCard.confirming
                                onClicked: {
                                    root._editingId  = modelData.ing.ingredientId
                                    root._editNameFr = modelData.ing.name   || ""
                                    root._editNameAr = modelData.ing.nameAr || ""
                                    root._editCat    = modelData.ing.category || "VEGETABLE"
                                    root._editUnit   = modelData.ing.unit     || "GR"
                                    root._addingNew  = false
                                    // Scroll header into view
                                    editFrInput.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
