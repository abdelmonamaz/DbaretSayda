#ifndef INGREDIENTMODEL_H
#define INGREDIENTMODEL_H

#include <QAbstractListModel>
#include <QList>

struct Ingredient {
    int ingredientId;
    QString name;
    QString nameAr;
    QString category;
    QString defaultUnit;
};

class IngredientModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum IngredientRole {
        IdRole = Qt::UserRole + 1,
        NameRole,
        NameArRole,
        CategoryRole,
        UnitRole
    };
    
    static IngredientModel& instance();
    
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    
    Q_INVOKABLE void loadFromDatabase();
    Ingredient getIngredient(int ingredientId) const;
    QList<Ingredient> getIngredientsByCategory(const QString& category) const;
    Q_INVOKABLE QVariantList allAsVariantList() const;
    Q_INVOKABLE void addIngredient(const QString& name, const QString& nameAr,
                                   const QString& category, const QString& unit);
    Q_INVOKABLE void updateIngredient(int id, const QString& name, const QString& nameAr,
                                      const QString& category, const QString& unit);
    Q_INVOKABLE void deleteIngredient(int ingredientId);

private:
    IngredientModel();
    ~IngredientModel();
    
    QList<Ingredient> m_ingredients;
    static IngredientModel* s_instance;
};

#endif // INGREDIENTMODEL_H
