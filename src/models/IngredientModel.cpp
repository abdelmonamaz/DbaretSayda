#include "IngredientModel.h"
#include "DatabaseManager.h"
#include "DishModel.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

IngredientModel* IngredientModel::s_instance = nullptr;

IngredientModel::IngredientModel() {
}

IngredientModel::~IngredientModel() {
}

IngredientModel& IngredientModel::instance() {
    if (!s_instance) {
        s_instance = new IngredientModel();
    }
    return *s_instance;
}

void IngredientModel::loadFromDatabase() {
    beginResetModel();
    m_ingredients.clear();
    
    QSqlQuery query;
    if (!query.exec("SELECT ingredientId, name, nameAr, category, defaultUnit FROM IngredientLibrary ORDER BY category, name")) {
        qWarning() << "Failed to load ingredients:" << query.lastError().text();
        endResetModel();
        return;
    }
    
    while (query.next()) {
        Ingredient ingredient;
        ingredient.ingredientId = query.value(0).toInt();
        ingredient.name = query.value(1).toString();
        ingredient.nameAr = query.value(2).toString();
        ingredient.category = query.value(3).toString();
        ingredient.defaultUnit = query.value(4).toString();
        m_ingredients.append(ingredient);
    }
    
    endResetModel();
}

int IngredientModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_ingredients.count();
}

QVariant IngredientModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_ingredients.count()) {
        return QVariant();
    }
    
    const Ingredient& ingredient = m_ingredients.at(index.row());
    
    switch (role) {
        case IdRole:
            return ingredient.ingredientId;
        case NameRole:
            return ingredient.name;
        case NameArRole:
            return ingredient.nameAr;
        case CategoryRole:
            return ingredient.category;
        case UnitRole:
            return ingredient.defaultUnit;
        default:
            return QVariant();
    }
}

QHash<int, QByteArray> IngredientModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole] = "ingredientId";
    roles[NameRole] = "name";
    roles[NameArRole] = "nameAr";
    roles[CategoryRole] = "category";
    roles[UnitRole] = "unit";
    return roles;
}

QVariantList IngredientModel::allAsVariantList() const {
    QVariantList result;
    for (const Ingredient& i : m_ingredients) {
        result.append(QVariantMap{
            {"ingredientId", i.ingredientId},
            {"name",         i.name},
            {"nameAr",       i.nameAr},
            {"category",     i.category},
            {"unit",         i.defaultUnit}
        });
    }
    return result;
}

void IngredientModel::addIngredient(const QString& name, const QString& nameAr,
                                     const QString& category, const QString& unit) {
    QSqlQuery q;
    q.prepare("INSERT INTO IngredientLibrary(name, nameAr, category, defaultUnit) VALUES (?,?,?,?)");
    q.addBindValue(name); q.addBindValue(nameAr);
    q.addBindValue(category); q.addBindValue(unit);
    if (!q.exec()) { qWarning() << "addIngredient:" << q.lastError().text(); return; }
    loadFromDatabase();
}

void IngredientModel::updateIngredient(int id, const QString& name, const QString& nameAr,
                                        const QString& category, const QString& unit) {
    QSqlQuery q;
    q.prepare("UPDATE IngredientLibrary SET name=?, nameAr=?, category=?, defaultUnit=? WHERE ingredientId=?");
    q.addBindValue(name.trimmed()); q.addBindValue(nameAr.trimmed());
    q.addBindValue(category); q.addBindValue(unit); q.addBindValue(id);
    if (!q.exec()) { qWarning() << "updateIngredient:" << q.lastError().text(); return; }
    loadFromDatabase();
}

void IngredientModel::deleteIngredient(int ingredientId) {
    QSqlQuery q;
    q.prepare("DELETE FROM DishIngredientCrossRef WHERE ingredientId=?");
    q.addBindValue(ingredientId);
    if (!q.exec()) qWarning() << "deleteIngredient (crossref):" << q.lastError().text();

    q.prepare("DELETE FROM IngredientLibrary WHERE ingredientId=?");
    q.addBindValue(ingredientId);
    if (!q.exec()) { qWarning() << "deleteIngredient:" << q.lastError().text(); return; }
    loadFromDatabase();
    DishModel::instance().loadFromDatabase();  // refresh ingredient counts
}

Ingredient IngredientModel::getIngredient(int ingredientId) const {
    for (const Ingredient& ing : m_ingredients) {
        if (ing.ingredientId == ingredientId) {
            return ing;
        }
    }
    return Ingredient();
}

QList<Ingredient> IngredientModel::getIngredientsByCategory(const QString& category) const {
    QList<Ingredient> result;
    for (const Ingredient& ing : m_ingredients) {
        if (ing.category == category) {
            result.append(ing);
        }
    }
    return result;
}
