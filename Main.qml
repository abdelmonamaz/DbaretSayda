import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    width: 390
    height: 844
    visible: true
    title: I18n.t('app.title')
    color: Theme.colors.bone

    // Mirror layout for Arabic RTL
    LayoutMirroring.enabled: I18n.currentLanguage === 'ar'
    LayoutMirroring.childrenInherit: true

    // ── Compteur de plats réactif ──────────────────────────────────────────
    property int _dishCount: 0

    Connections {
        target: dishModel
        function onModelReset()   { root._dishCount = dishModel.rowCount() }
        function onRowsInserted() { root._dishCount = dishModel.rowCount() }
        function onRowsRemoved()  { root._dishCount = dishModel.rowCount() }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Global app header ──────────────────────────────────────────────
        AppHeader {
            id: appHeader
            Layout.fillWidth: true
            dishCount: root._dishCount
            onGenerateMenuClicked: {
                weeklyPlanningModel.generateRandomMenu(appHeader.globalServings)
                shoppingListModel.generateForCurrentWeek()
            }
        }

        // ── Page area ──────────────────────────────────────────────────────
        StackLayout {
            id: pageStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            HomePage {
                onSelectDishForSlot: function(dayId, slotType) {
                    weeklyPlanningModel.assignRandomDish(dayId, slotType.toUpperCase(), appHeader.globalServings)
                    shoppingListModel.generateForCurrentWeek()
                }
            }
            DishesPage      {}
            ShoppingListPage{}
            SettingsPage    {}
        }

        // ── Bottom navigation ──────────────────────────────────────────────
        BottomNav {
            Layout.fillWidth: true
            currentIndex: pageStack.currentIndex
            onTabSelected: function(idx) { pageStack.currentIndex = idx }
        }
    }

    Component.onCompleted: {
        console.log("App started — language:", I18n.currentLanguage)
        root._dishCount = dishModel.rowCount()
    }
}
