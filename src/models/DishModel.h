#ifndef DISHMODEL_H
#define DISHMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QMap>
#include <QVariantList>

struct Dish {
    int     dishId;
    QString name;
    QString nameAr;
    QString type;          // STARTER | MAIN | DESSERT
    QString tone;          // olive | harissa | rose | saffron | tunis | makroudh | mint | cream
    QString imageUri;
    int     baseServings;
};

class DishModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum DishRole {
        IdRole = Qt::UserRole + 1,
        NameRole,
        NameArRole,
        TypeRole,
        ToneRole,
        ImageRole,
        BaseServingsRole,
        IngredientCountRole
    };

    static DishModel& instance();

    int      rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addDish(const Dish& dish);
    void updateDish(const Dish& dish);
    void removeDish(int dishId);
    Dish getDish(int dishId) const;

    Q_INVOKABLE void        loadFromDatabase();
    Q_INVOKABLE QVariantList dishesOfType(const QString& type) const;
    Q_INVOKABLE QVariantList ingredientsOfDish(int dishId) const;
    Q_INVOKABLE int          ingredientCount(int dishId) const;
    Q_INVOKABLE int          addDishQml(const QString& nameFr, const QString& nameAr,
                                        const QString& type,   const QString& tone, int baseServings = 4);
    Q_INVOKABLE void         updateDishQml(int dishId,
                                           const QString& nameFr, const QString& nameAr,
                                           const QString& type,   const QString& tone, int baseServings = 4);
    Q_INVOKABLE void         saveDishIngredients(int dishId, QVariantList ingredients);
    Q_INVOKABLE void         deleteDish(int dishId);

private:
    DishModel();
    ~DishModel();

    void loadIngredientCounts();

    QList<Dish>    m_dishes;
    QMap<int, int> m_ingredientCounts;   // dishId → ingredient count

    static DishModel* s_instance;
};

#endif // DISHMODEL_H
