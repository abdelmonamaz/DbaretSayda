import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Popup {
    id: root

    // ── Public API ────────────────────────────────────────────────────────
    property var editDish: null   // null = new dish, object = edit mode

    signal saveRequested(string nameFr, string nameAr, string type, string tone, int baseServings, var ingredients)

    // ── Internal state ────────────────────────────────────────────────────
    property string _nameFr:       ""
    property string _nameAr:       ""
    property string _type:         "MAIN"
    property string _tone:         "harissa"
    property int    _baseServings: 4
    property bool   _confirmDelete: false

    signal deleteRequested(int dishId)

    ListModel { id: ingredientsModel }

    readonly property bool _canSave: _nameFr.trim().length > 0

    function openNew() {
        editDish = null
        _nameFr = ""; _nameAr = ""; _type = "MAIN"; _tone = "harissa"; _baseServings = 4
        _confirmDelete = false
        ingredientsModel.clear()
        open()
    }

    function openEdit(dish) {
        _confirmDelete = false
        editDish = dish
        _nameFr       = dish.name         || ""
        _nameAr       = dish.nameAr       || ""
        _type         = dish.type         || "MAIN"
        _tone         = dish.tone         || "harissa"
        _baseServings = dish.baseServings || 4
        ingredientsModel.clear()
        var ingrs = dishModel.ingredientsOfDish(dish.dishId)
        for (var i = 0; i < ingrs.length; i++) ingredientsModel.append(ingrs[i])
        open()
    }

    function addIngredient(ingr) {
        ingredientsModel.append(ingr)
    }

    // ── Popup settings ─────────────────────────────────────────────────────
    x:     0
    y:     parent ? parent.height - height : 0
    width: parent ? parent.width : 390
    height: Math.max(560, parent ? parent.height * 0.92 : 560)

    modal:       true
    dim:         true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // ── Background ─────────────────────────────────────────────────────────
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

    // ── Slide-up animation ─────────────────────────────────────────────────
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 160; easing.type: Easing.InCubic }
    }

    // ── Ingredient DB manager popup ────────────────────────────────────────
    IngredientDBSheet {
        id: ingDbSheet
        parent: Overlay.overlay
    }

    // ── Ingredient picker (nested popup) ──────────────────────────────────
    IngredientPickerSheet {
        id: ingPicker
        parent: Overlay.overlay
        onManageBaseRequested: ingDbSheet.open()

        onConfirmed: function(selected) {
            // Snapshot existing items as plain JS objects BEFORE clearing
            var existingMap = {}
            for (var j = 0; j < ingredientsModel.count; j++) {
                var ex = ingredientsModel.get(j)
                existingMap[ex.ingredientId] = {
                    ingredientId: ex.ingredientId,
                    name:         ex.name,
                    unit:         ex.unit,
                    quantity:     ex.quantity
                }
            }
            ingredientsModel.clear()
            for (var i = 0; i < selected.length; i++) {
                var s = selected[i]
                var preserved = existingMap[s.ingredientId]
                ingredientsModel.append(preserved || {
                    ingredientId: s.ingredientId,
                    name:         s.name,
                    nameAr:       s.nameAr || "",
                    unit:         s.unit,
                    quantity:     0
                })
            }
        }
    }

    // ── Content ────────────────────────────────────────────────────────────
    contentItem: ScrollView {
        contentWidth: availableWidth
        clip: true

        Column {
            id: sheetCol
            width: parent.width
            spacing: 14
            topPadding:    14
            leftPadding:   18
            rightPadding:  18
            bottomPadding: 28
            // ── Drag handle ──────────────────────────────────────────────
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 42; height: 5; radius: 999
                color: "#241B1714"
            }

            // ── Title row ────────────────────────────────────────────────
            Item {
                width:  parent.width - 36
                height: Math.max(titleText.implicitHeight, 32)

                // × close — toujours à droite
                Text {
                    id:                 closeBtnX
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "×"
                    font.pixelSize: 24
                    font.family:    Theme.typography.fontUI
                    color:          Theme.colors.ink2
                    MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: root.close() }
                }

                // 🗑 Delete — juste à gauche du ×, visible uniquement en mode édition
                Item {
                    id: trashBtn
                    visible: root.editDish !== null
                    anchors { right: closeBtnX.left; rightMargin: 6; verticalCenter: parent.verticalCenter }
                    width: 30; height: 30

                    Rectangle {
                        anchors.fill: parent; radius: 8
                        color:        root._confirmDelete ? "#E75C3A" : Theme.colors.card
                        border.color: root._confirmDelete ? "#E75C3A" : "#241B1714"
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            width: 14; height: 14
                            source: "qrc:/icons/trash.svg"
                            sourceSize: Qt.size(28, 28)
                            fillMode: Image.PreserveAspectFit
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                colorization:      1.0
                                colorizationColor: root._confirmDelete ? "#ffffff" : Theme.colors.ink2
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; anchors.margins: -4
                        onClicked: root._confirmDelete = !root._confirmDelete
                    }
                }

                // Titre — de la gauche jusqu'au bouton poubelle (ou ×), alignement conditionnel
                Text {
                    id:                 titleText
                    anchors.left:           parent.left
                    anchors.right:          root.editDish !== null ? trashBtn.left : closeBtnX.left
                    anchors.rightMargin:    8
                    anchors.verticalCenter: parent.verticalCenter
                    text:               (I18n.currentLanguage, root.editDish ? I18n.t('dishes.editDish') : I18n.t('dishes.newDish'))
                    font.pixelSize:     26
                    font.family:        (I18n.currentLanguage === 'ar') ? "Aref Ruqaa" : Theme.typography.fontSerif
                    color:              Theme.colors.ink
                    horizontalAlignment: (I18n.currentLanguage === 'ar') ? Text.AlignRight : Text.AlignLeft
                }
            }

            // ── Bannière de confirmation suppression ──────────────────────
            Rectangle {
                visible: root.editDish !== null && root._confirmDelete
                width:   parent.width - 36
                height:  46; radius: 12
                color:        "#FFF0ED"
                border.color: "#E75C3A"; border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text:           (I18n.currentLanguage, I18n.t('dishes.confirmDelete'))
                        font.pixelSize: 13; font.family: Theme.typography.fontUI
                        font.weight:    Font.Medium; color: "#E75C3A"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: nonDelLbl.implicitWidth + 18; height: 30; radius: 8
                        color: Theme.colors.card; border.color: "#241B1714"; border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text { id: nonDelLbl; anchors.centerIn: parent; text: (I18n.currentLanguage, I18n.t('button.no')); font.pixelSize: 12; font.family: Theme.typography.fontUI; font.weight: Font.DemiBold; color: Theme.colors.ink }
                        MouseArea { anchors.fill: parent; onClicked: root._confirmDelete = false }
                    }

                    Rectangle {
                        width: supprLbl.implicitWidth + 18; height: 30; radius: 8
                        color: "#E75C3A"
                        anchors.verticalCenter: parent.verticalCenter
                        Text { id: supprLbl; anchors.centerIn: parent; text: (I18n.currentLanguage, I18n.t('button.delete')); font.pixelSize: 12; font.family: Theme.typography.fontUI; font.weight: Font.Bold; color: "#ffffff" }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { root.deleteRequested(root.editDish.dishId); root.close() }
                        }
                    }
                }
            }

            // ── FR Name ──────────────────────────────────────────────────
            Column {
                width: parent.width - 36
                spacing: 6

                Text {
                    text:                (I18n.currentLanguage, I18n.t('dishes.nameFr'))
                    font.pixelSize:      11; font.family: Theme.typography.fontUI; font.weight: Font.Bold
                    font.letterSpacing:  (I18n.currentLanguage === 'ar') ? 0 : 1.1
                    font.capitalization: (I18n.currentLanguage === 'ar') ? Font.MixedCase : Font.AllUppercase
                    color:               Theme.colors.ink2
                }

                Rectangle {
                    width:        parent.width
                    height:       52
                    color:        Theme.colors.bone
                    border.color: "#241B1714"
                    border.width: 1
                    radius:       12

                    Item {
                        anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 12; bottomMargin: 12 }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible:        frInput.text.length === 0
                            text:           "Couscous au poisson"
                            font.pixelSize: 18
                            font.family:    Theme.typography.fontSerif
                            color:          Theme.colors.ink3
                        }

                        TextInput {
                            id:                frInput
                            anchors.fill:      parent
                            text:              root._nameFr
                            font.pixelSize:    18
                            font.family:       Theme.typography.fontSerif
                            color:             Theme.colors.ink
                            verticalAlignment: TextInput.AlignVCenter
                            clip:              true
                            onTextEdited:      root._nameFr = text
                        }
                    }
                }
            }

            // ── AR Name ──────────────────────────────────────────────────
            Column {
                width: parent.width - 36
                spacing: 6

                Text {
                    text:                (I18n.currentLanguage, I18n.t('dishes.nameAr'))
                    font.pixelSize:      11; font.family: Theme.typography.fontUI; font.weight: Font.Bold
                    font.letterSpacing:  (I18n.currentLanguage === 'ar') ? 0 : 1.1
                    font.capitalization: (I18n.currentLanguage === 'ar') ? Font.MixedCase : Font.AllUppercase
                    color:               Theme.colors.ink2
                }

                Rectangle {
                    width:        parent.width
                    height:       52
                    color:        Theme.colors.bone
                    border.color: "#241B1714"
                    border.width: 1
                    radius:       12

                    Item {
                        anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 12; bottomMargin: 12 }

                        Text {
                            anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                            visible:        arInput.text.length === 0
                            text:           "كسكسي بالحوت"
                            font.pixelSize: 19
                            font.family:    "Tajawal"
                            color:          Theme.colors.ink3
                        }

                        TextInput {
                            id:                 arInput
                            anchors.fill:       parent
                            text:               root._nameAr
                            font.pixelSize:     19
                            font.family:        "Aref Ruqaa"
                            color:              Theme.colors.ink
                            horizontalAlignment:TextInput.AlignRight
                            verticalAlignment:  TextInput.AlignVCenter
                            clip:               true
                            onTextEdited:       root._nameAr = text
                        }
                    }
                }
            }

            // ── Category ─────────────────────────────────────────────────
            Column {
                width: parent.width - 36
                spacing: 6

                Text {
                    text:                (I18n.currentLanguage, I18n.t('dishes.category'))
                    font.pixelSize:      11; font.family: Theme.typography.fontUI; font.weight: Font.Bold
                    font.letterSpacing:  (I18n.currentLanguage === 'ar') ? 0 : 1.1
                    font.capitalization: (I18n.currentLanguage === 'ar') ? Font.MixedCase : Font.AllUppercase
                    color:               Theme.colors.ink2
                }

                Row {
                    width:   parent.width
                    spacing: 6

                    readonly property var cats: (I18n.currentLanguage, [
                        { id: "STARTER", label: I18n.t('dishes.categories.starter'), dot: "#6B9A50" },
                        { id: "MAIN",    label: I18n.t('dishes.categories.main'),    dot: Theme.colors.harissa.main },
                        { id: "DESSERT", label: I18n.t('dishes.categories.dessert'), dot: "#D49585" }
                    ])

                    Repeater {
                        model: parent.cats

                        Rectangle {
                            width:  (parent.width - 12) / 3
                            height: 44
                            radius: 12

                            readonly property bool sel: root._type === modelData.id
                            color:        sel ? Theme.colors.card : Theme.colors.bone
                            border.color: sel ? modelData.dot      : "#241B1714"
                            border.width: sel ? 2                  : 1

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: modelData.dot
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text:           modelData.label
                                    font.pixelSize: 13
                                    font.family:    Theme.typography.fontUI
                                    font.weight:    sel ? Font.Bold : Font.Medium
                                    color:          sel ? modelData.dot : Theme.colors.ink2
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked:    root._type = modelData.id
                            }
                        }
                    }
                }
            }

            // ── Base servings ─────────────────────────────────────────────
            Item {
                width:  parent.width - 36
                height: 44

                Text {
                    anchors.left:           parent.left
                    anchors.right:          baseStepperRow.left
                    anchors.rightMargin:    10
                    anchors.verticalCenter: parent.verticalCenter
                    text:                (I18n.currentLanguage, I18n.t('dishes.baseServings'))
                    font.pixelSize:      11
                    font.family:         Theme.typography.fontUI
                    font.weight:         Font.Bold
                    font.letterSpacing:  (I18n.currentLanguage === 'ar') ? 0 : 1.1
                    font.capitalization: (I18n.currentLanguage === 'ar') ? Font.MixedCase : Font.AllUppercase
                    color:               Theme.colors.ink2
                    horizontalAlignment: (I18n.currentLanguage === 'ar') ? Text.AlignRight : Text.AlignLeft
                }

                Row {
                    id: baseStepperRow
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }

                    Rectangle {
                        width: 36; height: 36
                        radius: 10
                        color: Theme.colors.card
                        border.color: "#241B1714"; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "−"
                            font.pixelSize: 18
                            font.family:    Theme.typography.fontUI
                            color:          root._baseServings > 1 ? Theme.colors.ink : Theme.colors.ink3
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (root._baseServings > 1) root._baseServings--
                        }
                    }

                    Rectangle {
                        width: 44; height: 36
                        radius: 10
                        color: Theme.colors.card
                        border.color: "#241B1714"; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text:           root._baseServings
                            font.pixelSize: 15
                            font.family:    Theme.typography.fontMono
                            font.weight:    Font.DemiBold
                            color:          Theme.colors.ink
                        }
                    }

                    Rectangle {
                        width: 36; height: 36
                        radius: 10
                        color: Theme.colors.card
                        border.color: "#241B1714"; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 18
                            font.family:    Theme.typography.fontUI
                            color:          root._baseServings < 20 ? Theme.colors.ink : Theme.colors.ink3
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (root._baseServings < 20) root._baseServings++
                        }
                    }
                }
            }

            // ── Color picker ─────────────────────────────────────────────
            Column {
                width: parent.width - 36
                spacing: 6

                Text {
                    text:                (I18n.currentLanguage, I18n.t('dishes.color'))
                    font.pixelSize:      11; font.family: Theme.typography.fontUI; font.weight: Font.Bold
                    font.letterSpacing:  (I18n.currentLanguage === 'ar') ? 0 : 1.1
                    font.capitalization: (I18n.currentLanguage === 'ar') ? Font.MixedCase : Font.AllUppercase
                    color:               Theme.colors.ink2
                }

                Row {
                    spacing: 7

                    readonly property var tones: [
                        { id: "olive",    color: Theme.colors.olive.main    },
                        { id: "cream",    color: Theme.colors.cream.main    },
                        { id: "harissa",  color: Theme.colors.harissa.main  },
                        { id: "saffron",  color: Theme.colors.saffron.main  },
                        { id: "tunis",    color: Theme.colors.tunis.main    },
                        { id: "makroudh", color: Theme.colors.makroudh.main },
                        { id: "mint",     color: Theme.colors.mint.main     }
                    ]

                    Repeater {
                        model: parent.tones

                        Item {
                            width:  38
                            height: 38

                            readonly property bool sel: root._tone === modelData.id

                            // Ring (visible when selected)
                            Rectangle {
                                anchors.centerIn: parent
                                width:  38; height: 38; radius: 999
                                color:   sel ? "#F4EEE4" : "transparent"
                            }

                            // Swatch
                            Rectangle {
                                anchors.centerIn: parent
                                width:  30; height: 30; radius: 999
                                color:        modelData.color
                                border.color: sel ? Theme.colors.ink : "#241B1714"
                                border.width: sel ? 2                : 1
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked:    root._tone = modelData.id
                            }
                        }
                    }
                }
            }

            // ── Ingredients ───────────────────────────────────────────────
            Column {
                width: parent.width - 36
                spacing: 6

                // Header
                Text {
                    text: (I18n.currentLanguage, I18n.t('dishes.ingredients') +
                          (ingredientsModel.count > 0 ? " · " + ingredientsModel.count : ""))
                    font.pixelSize:      11; font.family: Theme.typography.fontUI; font.weight: Font.Bold
                    font.letterSpacing:  (I18n.currentLanguage === 'ar') ? 0 : 1.1
                    font.capitalization: (I18n.currentLanguage === 'ar') ? Font.MixedCase : Font.AllUppercase
                    color:               Theme.colors.ink2
                }

                // Empty state
                Rectangle {
                    width:        parent.width
                    height:       46
                    visible:      ingredientsModel.count === 0
                    color:        Theme.colors.card
                    border.color: "#241B1714"
                    border.width: 1
                    radius:       12

                    Text {
                        anchors.centerIn: parent
                        text:           (I18n.currentLanguage, I18n.t('dishes.noIngredient'))
                        font.pixelSize: 13
                        font.family:    Theme.typography.fontUI
                        color:          Theme.colors.ink3
                    }
                }

                // Ingredient rows
                Repeater {
                    model: ingredientsModel

                    Rectangle {
                        width:        parent.width
                        height:       42
                        color:        Theme.colors.card
                        border.color: "#141B1714"
                        border.width: 1
                        radius:       12

                        RowLayout {
                            anchors { fill: parent; leftMargin: 10; rightMargin: 8; topMargin: 8; bottomMargin: 8 }
                            spacing: 8

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: "#6B9A50"
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                Layout.fillWidth: true
                                text:           (I18n.currentLanguage, (I18n.currentLanguage === 'ar' && nameAr) ? nameAr : name)
                                font.pixelSize: 13
                                font.family:    (I18n.currentLanguage === 'ar' && nameAr) ? "Tajawal" : Theme.typography.fontUI
                                font.weight:    Font.Medium
                                color:          Theme.colors.ink
                                elide:          Text.ElideRight
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Rectangle {
                                width:        64
                                height:       28
                                color:        Theme.colors.card
                                border.color: "#241B1714"
                                border.width: 1
                                radius:       8
                                Layout.alignment: Qt.AlignVCenter

                                TextInput {
                                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                                    font.pixelSize:      12
                                    font.family:         Theme.typography.fontUI
                                    color:               Theme.colors.ink2
                                    horizontalAlignment: TextInput.AlignHCenter
                                    verticalAlignment:   TextInput.AlignVCenter
                                    inputMethodHints:    Qt.ImhFormattedNumbersOnly
                                    selectByMouse:       true
                                    clip:                true
                                    validator: RegularExpressionValidator {
                                        regularExpression: /^[0-9]*\.?[0-9]*$/
                                    }
                                    Component.onCompleted: text = String(quantity || 0)
                                    onTextEdited: ingredientsModel.setProperty(
                                                      index, "quantity", parseFloat(text) || 0)
                                }
                            }

                            Text {
                                text:           (I18n.currentLanguage, I18n.t('ingredients.units.' + (unit || "GR")))
                                font.pixelSize: 11
                                font.family:    Theme.typography.fontMono
                                color:          Theme.colors.ink3
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item {
                                width:  22; height: 22
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    anchors.centerIn: parent
                                    text:           "×"
                                    font.pixelSize: 18
                                    font.family:    Theme.typography.fontUI
                                    color:          Theme.colors.ink3
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked:    ingredientsModel.remove(index)
                                }
                            }
                        }
                    }
                }

                // "Ajouter des ingrédients" button
                Rectangle {
                    width:        parent.width
                    height:       46
                    color:        "transparent"
                    radius:       12
                    border.color: Theme.colors.harissa.main
                    border.width: 1

                    // Dashed border simulation (Qt doesn't natively support dashed borders)
                    // We'll use a solid border with low opacity for now

                    Row {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text:           "+"
                            font.pixelSize: 18
                            font.family:    Theme.typography.fontUI
                            color:          Theme.colors.harissa.deep
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:           (I18n.currentLanguage, I18n.t('dishes.addIngredient'))
                            font.pixelSize: 13
                            font.family:    Theme.typography.fontUI
                            font.weight:    Font.Bold
                            color:          Theme.colors.harissa.deep
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var ids = []
                            for (var i = 0; i < ingredientsModel.count; i++)
                                ids.push(ingredientsModel.get(i).ingredientId)
                            ingPicker.openPicker(ids)
                        }
                    }
                }
            }

            // ── Footer buttons ────────────────────────────────────────────
            Row {
                width:   parent.width - 36
                spacing: 8
                topPadding: 4

                // Cancel
                Rectangle {
                    width:  (parent.width - 8) * 0.42
                    height: 52
                    radius: 14
                    color:        Theme.colors.card
                    border.color: "#241B1714"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text:           (I18n.currentLanguage, I18n.t('button.cancel'))
                        font.pixelSize: 14
                        font.family:    Theme.typography.fontUI
                        font.weight:    Font.DemiBold
                        color:          Theme.colors.ink
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked:    root.close()
                    }
                }

                // Save
                Rectangle {
                    width:  (parent.width - 8) * 0.58
                    height: 52
                    radius: 14
                    color:  root._canSave ? Theme.colors.harissa.main : "#241B1714"

                    Text {
                        anchors.centerIn: parent
                        text:           (I18n.currentLanguage, I18n.t('button.save'))
                        font.pixelSize: 14
                        font.family:    Theme.typography.fontUI
                        font.weight:    Font.Bold
                        color:          "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled:      root._canSave
                        onClicked: {
                            var ings = []
                            for (var i = 0; i < ingredientsModel.count; i++) {
                                var item = ingredientsModel.get(i)
                                ings.push({
                                    ingredientId: item.ingredientId,
                                    name:         item.name,
                                    unit:         item.unit,
                                    quantity:     item.quantity
                                })
                            }
                            root.saveRequested(root._nameFr, root._nameAr, root._type, root._tone, root._baseServings, ings)
                            root.close()
                        }
                    }
                }
            }
        }
    }
}
