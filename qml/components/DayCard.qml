import QtQuick
import QtQuick.Effects

Rectangle {
    id: dayCard

    required property int    dayId
    required property string dayLabel
    property bool   isToday:  false
    required property var    meals      // [{type, name, dishId, tone}]
    required property int servings
    property var    slotFilters: ['starter', 'main', 'dessert']

    signal selectDish(string slotType)
    signal servingsUpdated(int newServings)
    signal dishInfoRequested(int dishId, string dishName, string dishNameAr)

    // ── Date: DD.MM computed from dayId (0 = Monday) ──────────────────────
    readonly property string formattedDate: {
        var base   = new Date()
        var dow    = base.getDay()   // 0=Sun, 1=Mon …
        var monday = new Date(base)
        monday.setDate(base.getDate() - (dow === 0 ? 6 : dow - 1))
        var target = new Date(monday)
        target.setDate(monday.getDate() + dayId)
        return String(target.getDate()).padStart(2, '0') + "." +
               String(target.getMonth() + 1).padStart(2, '0')
    }

    color:        Theme.colors.card
    radius:       Theme.sizes.radius.xxxl   // 22
    border.color: "#0D1B1714"               // rgba(27,23,20,0.05)
    border.width: 1

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled:        true
        shadowColor:          "#2E1B1714"
        shadowVerticalOffset: 8
        shadowBlur:           0.45
    }

    implicitWidth:  320
    implicitHeight: cardCol.implicitHeight + 24   // 12 top + 12 bottom

    // ── Main content column ───────────────────────────────────────────────
    Column {
        id: cardCol
        anchors {
            top:         parent.top
            left:        parent.left
            right:       parent.right
            topMargin:   12
            leftMargin:  14
            rightMargin: 12
        }
        spacing: 4

        // ── Header ───────────────────────────────────────────────────────
        Item {
            width:  parent.width
            height: Math.max(dayNameText.implicitHeight, servingsToggle.implicitHeight) + 10

            Row {
                anchors {
                    left:           parent.left
                    verticalCenter: parent.verticalCenter
                }
                spacing: 8

                Text {
                    id:             dayNameText
                    text:           dayLabel
                    color:          Theme.colors.ink
                    font.pixelSize: Theme.typography.dayLabelSize   // 22
                    font.family:    Theme.typography.fontSerif
                }

                Text {
                    text:               dayCard.formattedDate
                    color:              Theme.colors.ink3
                    font.pixelSize:     10
                    font.family:        Theme.typography.fontMono
                    font.letterSpacing: 0.8   // 0.08em × 10
                    anchors.baseline:   dayNameText.baseline
                }
            }

            ServingsToggle {
                id: servingsToggle
                anchors {
                    right:          parent.right
                    verticalCenter: parent.verticalCenter
                }
                value: dayCard.servings
                onValueChanged: {
                    console.log(dayCard.servings)
                    // Skip model-driven updates: when the binding above sets value,
                    // it equals dayCard.servings. Only user presses change value first.
                    if (value === dayCard.servings) return
                    dayCard.servings = value
                    dayCard.servingsUpdated(value)
                }
            }
        }

        // ── Meal slots ────────────────────────────────────────────────────
        Repeater {
            model: 3

            Item {
                id:      slotWrapper
                width:   parent.width
                readonly property string mealType: index === 0 ? 'starter' : (index === 1 ? 'main' : 'dessert')
                readonly property var    meal:     (dayCard.meals && index < dayCard.meals.length) ? dayCard.meals[index] : null
                readonly property bool   shown:    dayCard.slotFilters.indexOf(mealType) !== -1
                height: shown ? slotInner.implicitHeight : 0
                clip:   true

                Slot {
                    id:         slotInner
                    width:      parent.width
                    visible:    parent.shown
                    type:       parent.mealType
                    dishName:   parent.meal ? (parent.meal.name   || "") : ""
                    dishNameAr: parent.meal ? (parent.meal.nameAr || "") : ""
                    dishId:     parent.meal ? parent.meal.dishId : -1
                    tone:       parent.meal ? (parent.meal.tone || "harissa") : "harissa"
                    onSwapped:  dayCard.selectDish(parent.mealType)
                    onDishInfoRequested: {
                        if (slotInner.dishId > 0)
                            dayCard.dishInfoRequested(
                                slotInner.dishId,
                                parent.meal ? (parent.meal.name   || "") : "",
                                parent.meal ? (parent.meal.nameAr || "") : "")
                    }
                }
            }
        }
    }

    // ── "Aujourd'hui" badge ────────────────────────────────────────────────
    Item {
        id:      todayBadge
        visible: isToday
        anchors { top: parent.top; right: parent.right }
        width:  todayText.implicitWidth + 20
        height: todayText.implicitHeight + 8

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = Theme.colors.ink
                var rBL = 10   // bottom-left radius (design spec)
                var rTR = 22   // top-right matches card corner
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(width - rTR, 0)
                ctx.arcTo(width, 0, width, rTR, rTR)
                ctx.lineTo(width, height)
                ctx.lineTo(rBL, height)
                ctx.arcTo(0, height, 0, height - rBL, rBL)
                ctx.closePath()
                ctx.fill()
            }
            Component.onCompleted: requestPaint()
            onWidthChanged:        requestPaint()
            onHeightChanged:       requestPaint()
        }

        Text {
            id:                  todayText
            anchors.centerIn:    parent
            text:                (I18n.currentLanguage, I18n.t('home.today'))
            color:               "#FFFFFF"
            font.pixelSize:      10
            font.family:         Theme.typography.fontUI
            font.weight:         Font.Bold
            font.letterSpacing:  1.4
            font.capitalization: Font.AllUppercase
        }
    }
}
