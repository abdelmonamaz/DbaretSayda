#ifndef SHOPPINGLISTMODEL_H
#define SHOPPINGLISTMODEL_H

#include <QAbstractListModel>
#include <QList>

struct ShoppingItem {
    int ingredientId;
    QString name;
    QString nameAr;
    QString category;
    double totalQuantity;
    QString unit;
    bool isChecked;
};

class ShoppingListModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum ShoppingItemRole {
        IdRole = Qt::UserRole + 1,
        NameRole,
        NameArRole,
        CategoryRole,
        QuantityRole,
        UnitRole,
        CheckedRole
    };
    
    static ShoppingListModel& instance();
    
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    
    Q_INVOKABLE void generateForCurrentWeek();
    Q_INVOKABLE void setMealTypeFilter(const QVariantList& types);
    Q_INVOKABLE void toggleItemChecked(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantList allAsVariantList() const;

private:
    ShoppingListModel();
    ~ShoppingListModel();

    QList<ShoppingItem> m_shoppingItems;
    QStringList         m_mealTypeFilter;   // empty = all types
    static ShoppingListModel* s_instance;
};

#endif // SHOPPINGLISTMODEL_H
