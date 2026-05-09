#include "ShoppingListModel.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDate>
#include <QMap>

ShoppingListModel* ShoppingListModel::s_instance = nullptr;

ShoppingListModel::ShoppingListModel() {
}

ShoppingListModel::~ShoppingListModel() {
}

ShoppingListModel& ShoppingListModel::instance() {
    if (!s_instance) {
        s_instance = new ShoppingListModel();
    }
    return *s_instance;
}

void ShoppingListModel::generateForCurrentWeek() {
    beginResetModel();
    m_shoppingItems.clear();
    
    // Get current week number
    int weekNumber = QDate::currentDate().weekNumber();
    
    // Map to aggregate quantities by ingredient
    QMap<int, ShoppingItem> aggregatedItems;
    
    // Query all dishes planned for this week, optionally filtered by meal type
    QString planSql =
        "SELECT wp.dishId, wp.plannedServings, d.baseServings "
        "FROM WeeklyPlanning wp "
        "JOIN Dish d ON wp.dishId = d.dishId "
        "WHERE wp.weekId = ?";
    if (!m_mealTypeFilter.isEmpty()) {
        QStringList quoted;
        for (const QString& t : m_mealTypeFilter) quoted << "'" + t + "'";
        planSql += " AND d.type IN (" + quoted.join(",") + ")";
    }

    QSqlQuery planQuery;
    planQuery.prepare(planSql);
    planQuery.addBindValue(weekNumber);
    
    if (!planQuery.exec()) {
        qWarning() << "Failed to query weekly planning:" << planQuery.lastError().text();
        endResetModel();
        return;
    }
    
    // For each planned dish, get its ingredients and calculate quantities
    while (planQuery.next()) {
        int dishId = planQuery.value(0).toInt();
        int plannedServings = planQuery.value(1).toInt();
        int baseServings = planQuery.value(2).toInt();
        
        // Get ingredients for this dish
        QSqlQuery ingredientQuery;
        ingredientQuery.prepare(
            "SELECT dic.ingredientId, dic.quantity, il.name, il.nameAr, il.category, il.defaultUnit "
            "FROM DishIngredientCrossRef dic "
            "JOIN IngredientLibrary il ON dic.ingredientId = il.ingredientId "
            "WHERE dic.dishId = ?"
        );
        ingredientQuery.addBindValue(dishId);
        
        if (!ingredientQuery.exec()) {
            qWarning() << "Failed to query dish ingredients:" << ingredientQuery.lastError().text();
            continue;
        }
        
        while (ingredientQuery.next()) {
            int ingredientId = ingredientQuery.value(0).toInt();
            double baseQuantity = ingredientQuery.value(1).toDouble();
            QString name = ingredientQuery.value(2).toString();
            QString nameAr = ingredientQuery.value(3).toString();
            QString category = ingredientQuery.value(4).toString();
            QString unit = ingredientQuery.value(5).toString();
            
            // Calculate: (baseQty / baseServings) × plannedServings
            double finalQuantity = (baseQuantity / baseServings) * plannedServings;
            
            if (aggregatedItems.contains(ingredientId)) {
                // Aggregate with existing item
                aggregatedItems[ingredientId].totalQuantity += finalQuantity;
            } else {
                // Create new item
                ShoppingItem item;
                item.ingredientId = ingredientId;
                item.name = name;
                item.nameAr = nameAr;
                item.category = category;
                item.totalQuantity = finalQuantity;
                item.unit = unit;
                item.isChecked = false;
                aggregatedItems[ingredientId] = item;
            }
        }
    }
    
    // Convert map to list, sorted by category
    QMap<QString, QList<ShoppingItem>> byCategory;
    for (const ShoppingItem& item : aggregatedItems.values()) {
        byCategory[item.category].append(item);
    }
    
    // Add items to model grouped by category
    for (const QString& category : byCategory.keys()) {
        for (const ShoppingItem& item : byCategory[category]) {
            m_shoppingItems.append(item);
        }
    }
    
    endResetModel();
}

int ShoppingListModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_shoppingItems.count();
}

QVariant ShoppingListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_shoppingItems.count()) {
        return QVariant();
    }
    
    const ShoppingItem& item = m_shoppingItems.at(index.row());
    
    switch (role) {
        case IdRole:
            return item.ingredientId;
        case NameRole:
            return item.name;
        case NameArRole:
            return item.nameAr;
        case CategoryRole:
            return item.category;
        case QuantityRole:
            return item.totalQuantity;
        case UnitRole:
            return item.unit;
        case CheckedRole:
            return item.isChecked;
        default:
            return QVariant();
    }
}

QHash<int, QByteArray> ShoppingListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole] = "ingredientId";
    roles[NameRole] = "name";
    roles[NameArRole] = "nameAr";
    roles[CategoryRole] = "category";
    roles[QuantityRole] = "quantity";
    roles[UnitRole] = "unit";
    roles[CheckedRole] = "isChecked";
    return roles;
}

void ShoppingListModel::setMealTypeFilter(const QVariantList& types) {
    m_mealTypeFilter.clear();
    for (const QVariant& v : types) {
        QString t = v.toString().toUpper();
        if (t == "STARTER" || t == "MAIN" || t == "DESSERT")
            m_mealTypeFilter << t;
    }
    generateForCurrentWeek();
}

void ShoppingListModel::toggleItemChecked(int index) {
    if (index >= 0 && index < m_shoppingItems.count()) {
        m_shoppingItems[index].isChecked = !m_shoppingItems[index].isChecked;
        QModelIndex modelIndex = createIndex(index, 0);
        emit dataChanged(modelIndex, modelIndex, { CheckedRole });
    }
}

QVariantList ShoppingListModel::allAsVariantList() const {
    QVariantList result;
    for (int i = 0; i < m_shoppingItems.count(); ++i) {
        const ShoppingItem& s = m_shoppingItems.at(i);
        result.append(QVariantMap{
            {"ingredientId", s.ingredientId}, {"name",      s.name},
            {"nameAr",       s.nameAr},       {"category",  s.category},
            {"quantity",     s.totalQuantity}, {"unit",      s.unit},
            {"isChecked",    s.isChecked},    {"modelIndex", i}
        });
    }
    return result;
}

void ShoppingListModel::clear() {
    beginResetModel();
    m_shoppingItems.clear();
    endResetModel();
}
