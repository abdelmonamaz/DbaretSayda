#include "WeeklyPlanningModel.h"
#include "ShoppingListModel.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDate>
#include <QLocale>
#include <QRandomGenerator>

WeeklyPlanningModel* WeeklyPlanningModel::s_instance = nullptr;

WeeklyPlanningModel::WeeklyPlanningModel() {
}

WeeklyPlanningModel::~WeeklyPlanningModel() {
}

WeeklyPlanningModel& WeeklyPlanningModel::instance() {
    if (!s_instance) {
        s_instance = new WeeklyPlanningModel();
    }
    return *s_instance;
}

int WeeklyPlanningModel::getCurrentWeekNumber() const {
    return QDate::currentDate().weekNumber();
}

void WeeklyPlanningModel::generateRandomMenu(int defaultServings) {
    QSqlQuery q;
    QList<int> starters, mains, desserts;

    if (q.exec("SELECT dishId FROM Dish WHERE type='STARTER'"))
        while (q.next()) starters << q.value(0).toInt();
    if (q.exec("SELECT dishId FROM Dish WHERE type='MAIN'"))
        while (q.next()) mains << q.value(0).toInt();
    if (q.exec("SELECT dishId FROM Dish WHERE type='DESSERT'"))
        while (q.next()) desserts << q.value(0).toInt();

    if (starters.isEmpty() && mains.isEmpty() && desserts.isEmpty()) return;

    int weekNumber = getCurrentWeekNumber();
    q.prepare("DELETE FROM WeeklyPlanning WHERE weekId=?");
    q.addBindValue(weekNumber);
    q.exec();

    for (int dayId = 0; dayId < 7; ++dayId) {
        auto insert = [&](int dishId, const QString& mealType) {
            q.prepare("INSERT INTO WeeklyPlanning(weekId,dayId,dishId,mealType,plannedServings) VALUES(?,?,?,?,?)");
            q.addBindValue(weekNumber); q.addBindValue(dayId); q.addBindValue(dishId);
            q.addBindValue(mealType);   q.addBindValue(defaultServings);
            q.exec();
        };
        if (!starters.isEmpty())
            insert(starters[QRandomGenerator::global()->bounded((uint)starters.size())], "STARTER");
        if (!mains.isEmpty())
            insert(mains[QRandomGenerator::global()->bounded((uint)mains.size())], "MAIN");
        if (!desserts.isEmpty())
            insert(desserts[QRandomGenerator::global()->bounded((uint)desserts.size())], "DESSERT");
    }
    loadForCurrentWeek();
}

void WeeklyPlanningModel::assignRandomDish(int dayId, const QString& mealType, int servings) {
    QSqlQuery q;
    QList<int> dishes;
    q.prepare("SELECT dishId FROM Dish WHERE type=?");
    q.addBindValue(mealType.toUpper());
    if (q.exec()) while (q.next()) dishes << q.value(0).toInt();
    if (dishes.isEmpty()) return;

    int dishId = dishes[QRandomGenerator::global()->bounded((uint)dishes.size())];
    int weekNumber = getCurrentWeekNumber();

    q.prepare("DELETE FROM WeeklyPlanning WHERE weekId=? AND dayId=? AND mealType=?");
    q.addBindValue(weekNumber); q.addBindValue(dayId); q.addBindValue(mealType.toUpper());
    q.exec();

    q.prepare("INSERT INTO WeeklyPlanning(weekId,dayId,dishId,mealType,plannedServings) VALUES(?,?,?,?,?)");
    q.addBindValue(weekNumber); q.addBindValue(dayId); q.addBindValue(dishId);
    q.addBindValue(mealType.toUpper()); q.addBindValue(servings);
    q.exec();

    loadForCurrentWeek();
}

void WeeklyPlanningModel::loadForCurrentWeek() {
    beginResetModel();
    m_weeklyMeals.clear();
    
    for (int i = 0; i < 7; ++i) {
        DayMeal dayMeal;
        dayMeal.dayId         = i;
        dayMeal.starterDishId = 0; dayMeal.starterName = ""; dayMeal.starterNameAr = ""; dayMeal.starterTone = "harissa";
        dayMeal.mainDishId    = 0; dayMeal.mainName    = ""; dayMeal.mainNameAr    = ""; dayMeal.mainTone    = "harissa";
        dayMeal.dessertDishId = 0; dayMeal.dessertName = ""; dayMeal.dessertNameAr = ""; dayMeal.dessertTone = "harissa";
        dayMeal.servings = 4;
        m_weeklyMeals.append(dayMeal);
    }
    
    // Load from database for current week
    int weekNumber = getCurrentWeekNumber();
    QSqlQuery query;
    query.prepare("SELECT wp.dayId, wp.dishId, d.name, d.type, wp.plannedServings, d.tone, d.nameAr "
                  "FROM WeeklyPlanning wp "
                  "JOIN Dish d ON wp.dishId = d.dishId "
                  "WHERE wp.weekId = ?");
    query.addBindValue(weekNumber);
    
    if (!query.exec()) {
        qWarning() << "Failed to load weekly planning:" << query.lastError().text();
        endResetModel();
        return;
    }
    
    while (query.next()) {
        int     dayId          = query.value(0).toInt();
        int     dishId         = query.value(1).toInt();
        QString dishName       = query.value(2).toString();
        QString dishType       = query.value(3).toString();
        int     plannedServings= query.value(4).toInt();
        QString dishTone       = query.value(5).toString();
        QString dishNameAr     = query.value(6).toString();
        if (dishTone.isEmpty()) dishTone = "harissa";

        if (dayId >= 0 && dayId < m_weeklyMeals.count()) {
            DayMeal& dayMeal = m_weeklyMeals[dayId];
            dayMeal.servings = plannedServings;
            if (dishType == "STARTER") {
                dayMeal.starterDishId = dishId; dayMeal.starterName = dishName;
                dayMeal.starterNameAr = dishNameAr; dayMeal.starterTone = dishTone;
            } else if (dishType == "MAIN") {
                dayMeal.mainDishId = dishId; dayMeal.mainName = dishName;
                dayMeal.mainNameAr = dishNameAr; dayMeal.mainTone = dishTone;
            } else if (dishType == "DESSERT") {
                dayMeal.dessertDishId = dishId; dayMeal.dessertName = dishName;
                dayMeal.dessertNameAr = dishNameAr; dayMeal.dessertTone = dishTone;
            }
        }
    }
    
    endResetModel();
}

int WeeklyPlanningModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_weeklyMeals.count();
}

QVariant WeeklyPlanningModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_weeklyMeals.count()) {
        return QVariant();
    }
    
    const DayMeal& dayMeal = m_weeklyMeals.at(index.row());
    
    switch (role) {
        case DayIdRole:          return dayMeal.dayId;
        case StarterDishIdRole:  return dayMeal.starterDishId;
        case StarterNameRole:    return dayMeal.starterName;
        case StarterNameArRole:  return dayMeal.starterNameAr;
        case MainDishIdRole:     return dayMeal.mainDishId;
        case MainNameRole:       return dayMeal.mainName;
        case MainNameArRole:     return dayMeal.mainNameAr;
        case DessertDishIdRole:  return dayMeal.dessertDishId;
        case DessertNameRole:    return dayMeal.dessertName;
        case DessertNameArRole:  return dayMeal.dessertNameAr;
        case StarterToneRole:    return dayMeal.starterTone;
        case MainToneRole:       return dayMeal.mainTone;
        case DessertToneRole:    return dayMeal.dessertTone;
        case ServingsRole:       return dayMeal.servings;
        default:                 return QVariant();
    }
}

QHash<int, QByteArray> WeeklyPlanningModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[DayIdRole]         = "dayId";
    roles[StarterDishIdRole] = "starterDishId";
    roles[StarterNameRole]   = "starterName";
    roles[StarterNameArRole] = "starterNameAr";
    roles[MainDishIdRole]    = "mainDishId";
    roles[MainNameRole]      = "mainName";
    roles[MainNameArRole]    = "mainNameAr";
    roles[DessertDishIdRole] = "dessertDishId";
    roles[DessertNameRole]   = "dessertName";
    roles[DessertNameArRole] = "dessertNameAr";
    roles[StarterToneRole]   = "starterTone";
    roles[MainToneRole]      = "mainTone";
    roles[DessertToneRole]   = "dessertTone";
    roles[ServingsRole]      = "servings";
    return roles;
}

void WeeklyPlanningModel::updateDayServings(int dayId, int servings) {
    if (dayId < 0 || dayId >= m_weeklyMeals.count()) return;

    QSqlQuery q;
    q.prepare("UPDATE WeeklyPlanning SET plannedServings=? WHERE weekId=? AND dayId=?");
    q.addBindValue(servings);
    q.addBindValue(getCurrentWeekNumber());
    q.addBindValue(dayId);
    if (!q.exec()) { qWarning() << "updateDayServings:" << q.lastError().text(); return; }

    m_weeklyMeals[dayId].servings = servings;
    QModelIndex mi = index(dayId);
    emit dataChanged(mi, mi, { ServingsRole });

    ShoppingListModel::instance().generateForCurrentWeek();
}

void WeeklyPlanningModel::updateDayPlanning(int dayId, int starterDishId, int mainDishId, int dessertDishId, int servings) {
    if (dayId < 0 || dayId >= m_weeklyMeals.count()) {
        return;
    }
    
    int weekNumber = getCurrentWeekNumber();
    
    // Update database
    QSqlQuery query;
    
    // First, clear existing entries for this day
    query.prepare("DELETE FROM WeeklyPlanning WHERE weekId = ? AND dayId = ?");
    query.addBindValue(weekNumber);
    query.addBindValue(dayId);
    query.exec();
    
    // Insert new entries if dishIds are not 0
    if (starterDishId > 0) {
        query.prepare("INSERT INTO WeeklyPlanning (weekId, dayId, dishId, mealType, plannedServings) VALUES (?, ?, ?, 'STARTER', ?)");
        query.addBindValue(weekNumber);
        query.addBindValue(dayId);
        query.addBindValue(starterDishId);
        query.addBindValue(servings);
        query.exec();
    }

    if (mainDishId > 0) {
        query.prepare("INSERT INTO WeeklyPlanning (weekId, dayId, dishId, mealType, plannedServings) VALUES (?, ?, ?, 'MAIN', ?)");
        query.addBindValue(weekNumber);
        query.addBindValue(dayId);
        query.addBindValue(mainDishId);
        query.addBindValue(servings);
        query.exec();
    }

    if (dessertDishId > 0) {
        query.prepare("INSERT INTO WeeklyPlanning (weekId, dayId, dishId, mealType, plannedServings) VALUES (?, ?, ?, 'DESSERT', ?)");
        query.addBindValue(weekNumber);
        query.addBindValue(dayId);
        query.addBindValue(dessertDishId);
        query.addBindValue(servings);
        query.exec();
    }
    
    // Update in-memory model
    DayMeal& dayMeal = m_weeklyMeals[dayId];
    dayMeal.servings = servings;
    
    // Reload to get fresh data with names
    loadForCurrentWeek();
}

DayMeal WeeklyPlanningModel::getDayMeal(int dayId) const {
    if (dayId >= 0 && dayId < m_weeklyMeals.count()) {
        return m_weeklyMeals.at(dayId);
    }
    return DayMeal();
}
