#ifndef WEEKLYPLANNINGMODEL_H
#define WEEKLYPLANNINGMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QDate>

struct DayMeal {
    int dayId;       // 0=Mon, 1=Tue, ..., 6=Sun
    int starterDishId;
    QString starterName;
    QString starterNameAr;
    QString starterTone;
    int mainDishId;
    QString mainName;
    QString mainNameAr;
    QString mainTone;
    int dessertDishId;
    QString dessertName;
    QString dessertNameAr;
    QString dessertTone;
    int servings;
};

class WeeklyPlanningModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum DayRole {
        DayIdRole = Qt::UserRole + 1,
        StarterDishIdRole,
        StarterNameRole,
        StarterNameArRole,
        MainDishIdRole,
        MainNameRole,
        MainNameArRole,
        DessertDishIdRole,
        DessertNameRole,
        DessertNameArRole,
        StarterToneRole,
        MainToneRole,
        DessertToneRole,
        ServingsRole
    };

    static WeeklyPlanningModel& instance();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadForCurrentWeek();
    Q_INVOKABLE void generateRandomMenu(int defaultServings = 4);
    Q_INVOKABLE void assignRandomDish(int dayId, const QString& mealType, int servings = 4);
    Q_INVOKABLE void updateDayPlanning(int dayId, int starterDishId, int mainDishId, int dessertDishId, int servings);
    Q_INVOKABLE void updateDayServings(int dayId, int servings);
    Q_INVOKABLE DayMeal getDayMeal(int dayId) const;

private:
    WeeklyPlanningModel();
    ~WeeklyPlanningModel();

    QList<DayMeal> m_weeklyMeals;
    static WeeklyPlanningModel* s_instance;

    int getCurrentWeekNumber() const;
};

#endif // WEEKLYPLANNINGMODEL_H
