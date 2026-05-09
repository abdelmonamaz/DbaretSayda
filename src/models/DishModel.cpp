#include "DishModel.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

DishModel* DishModel::s_instance = nullptr;

DishModel::DishModel() {}
DishModel::~DishModel() {}

DishModel& DishModel::instance() {
    if (!s_instance) s_instance = new DishModel();
    return *s_instance;
}

// ── QAbstractListModel ────────────────────────────────────────────────────

int DishModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return m_dishes.count();
}

QVariant DishModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_dishes.count()) return {};
    const Dish& d = m_dishes.at(index.row());
    switch (role) {
        case IdRole:             return d.dishId;
        case NameRole:           return d.name;
        case NameArRole:         return d.nameAr;
        case TypeRole:           return d.type;
        case ToneRole:           return d.tone;
        case ImageRole:          return d.imageUri;
        case BaseServingsRole:   return d.baseServings;
        case IngredientCountRole:return m_ingredientCounts.value(d.dishId, 0);
        default:                 return {};
    }
}

QHash<int, QByteArray> DishModel::roleNames() const {
    return {
        { IdRole,              "dishId"          },
        { NameRole,            "name"            },
        { NameArRole,          "nameAr"          },
        { TypeRole,            "type"            },
        { ToneRole,            "tone"            },
        { ImageRole,           "image"           },
        { BaseServingsRole,    "baseServings"    },
        { IngredientCountRole, "ingredientCount" }
    };
}

// ── Internal helpers ──────────────────────────────────────────────────────

void DishModel::addDish(const Dish& dish) {
    beginInsertRows({}, m_dishes.count(), m_dishes.count());
    m_dishes.append(dish);
    endInsertRows();
}

void DishModel::updateDish(const Dish& dish) {
    for (int i = 0; i < m_dishes.count(); ++i) {
        if (m_dishes[i].dishId == dish.dishId) {
            m_dishes[i] = dish;
            emit dataChanged(index(i), index(i));
            return;
        }
    }
}

void DishModel::removeDish(int dishId) {
    for (int i = 0; i < m_dishes.count(); ++i) {
        if (m_dishes[i].dishId == dishId) {
            beginRemoveRows({}, i, i);
            m_dishes.removeAt(i);
            endRemoveRows();
            return;
        }
    }
}

Dish DishModel::getDish(int dishId) const {
    for (const Dish& d : m_dishes)
        if (d.dishId == dishId) return d;
    return {-1, "", "", "", "", "", 0};
}

void DishModel::loadIngredientCounts() {
    m_ingredientCounts.clear();
    QSqlQuery q("SELECT dishId, COUNT(*) FROM DishIngredientCrossRef GROUP BY dishId");
    while (q.next())
        m_ingredientCounts[q.value(0).toInt()] = q.value(1).toInt();
}

// ── Q_INVOKABLE ───────────────────────────────────────────────────────────

void DishModel::loadFromDatabase() {
    QSqlQuery q("SELECT dishId, name, nameAr, type, tone, imageUri, baseServings "
                "FROM Dish ORDER BY type, name");
    beginResetModel();
    m_dishes.clear();
    while (q.next()) {
        Dish d;
        d.dishId       = q.value(0).toInt();
        d.name         = q.value(1).toString();
        d.nameAr       = q.value(2).toString();
        d.type         = q.value(3).toString();
        d.tone         = q.value(4).toString().isEmpty() ? "harissa" : q.value(4).toString();
        d.imageUri     = q.value(5).toString();
        d.baseServings = q.value(6).toInt();
        m_dishes.append(d);
    }
    endResetModel();
    loadIngredientCounts();
}

QVariantList DishModel::dishesOfType(const QString& type) const {
    QVariantList result;
    for (const Dish& d : m_dishes) {
        if (d.type.compare(type, Qt::CaseInsensitive) == 0) {
            result.append(QVariantMap{
                { "dishId",          d.dishId },
                { "name",            d.name   },
                { "nameAr",          d.nameAr },
                { "type",            d.type   },
                { "tone",            d.tone   },
                { "ingredientCount", m_ingredientCounts.value(d.dishId, 0) }
            });
        }
    }
    return result;
}

int DishModel::ingredientCount(int dishId) const {
    return m_ingredientCounts.value(dishId, 0);
}

QVariantList DishModel::ingredientsOfDish(int dishId) const {
    QSqlQuery q;
    q.prepare("SELECT dic.ingredientId, il.name, il.nameAr, il.defaultUnit, dic.quantity "
              "FROM DishIngredientCrossRef dic "
              "JOIN IngredientLibrary il ON dic.ingredientId = il.ingredientId "
              "WHERE dic.dishId=? ORDER BY il.name");
    q.addBindValue(dishId);
    QVariantList result;
    if (!q.exec()) { qWarning() << "ingredientsOfDish:" << q.lastError().text(); return result; }
    while (q.next()) {
        result.append(QVariantMap{
            {"ingredientId", q.value(0).toInt()},
            {"name",         q.value(1).toString()},
            {"nameAr",       q.value(2).toString()},
            {"unit",         q.value(3).toString()},
            {"quantity",     q.value(4).toDouble()}
        });
    }
    return result;
}

void DishModel::saveDishIngredients(int dishId, QVariantList ingredients) {
    QSqlQuery q;
    q.prepare("DELETE FROM DishIngredientCrossRef WHERE dishId=?");
    q.addBindValue(dishId);
    q.exec();
    for (const QVariant& v : ingredients) {
        QVariantMap ing = v.toMap();
        int ingId  = ing["ingredientId"].toInt();
        double qty = ing["quantity"].toDouble();
        if (ingId > 0) {
            q.prepare("INSERT INTO DishIngredientCrossRef(dishId,ingredientId,quantity) VALUES(?,?,?)");
            q.addBindValue(dishId); q.addBindValue(ingId); q.addBindValue(qty);
            q.exec();
        }
    }
    loadIngredientCounts();
    for (int i = 0; i < m_dishes.count(); ++i) {
        if (m_dishes[i].dishId == dishId) {
            emit dataChanged(index(i), index(i), {IngredientCountRole});
            break;
        }
    }
}

int DishModel::addDishQml(const QString& nameFr, const QString& nameAr,
                            const QString& type,   const QString& tone, int baseServings) {
    QSqlQuery q;
    q.prepare("INSERT INTO Dish(name, nameAr, type, tone, baseServings) VALUES (?,?,?,?,?)");
    q.addBindValue(nameFr); q.addBindValue(nameAr);
    q.addBindValue(type.toUpper()); q.addBindValue(tone); q.addBindValue(baseServings);
    if (!q.exec()) { qWarning() << "addDishQml:" << q.lastError().text(); return -1; }
    int newId = q.lastInsertId().toInt();
    Dish d{ newId, nameFr, nameAr, type.toUpper(), tone, "", baseServings };
    addDish(d);
    return newId;
}

void DishModel::updateDishQml(int dishId,
                               const QString& nameFr, const QString& nameAr,
                               const QString& type,   const QString& tone, int baseServings) {
    QSqlQuery q;
    q.prepare("UPDATE Dish SET name=?, nameAr=?, type=?, tone=?, baseServings=? WHERE dishId=?");
    q.addBindValue(nameFr);
    q.addBindValue(nameAr);
    q.addBindValue(type.toUpper());
    q.addBindValue(tone);
    q.addBindValue(baseServings);
    q.addBindValue(dishId);
    if (!q.exec()) { qWarning() << "updateDishQml:" << q.lastError().text(); return; }
    Dish d = getDish(dishId);
    d.name = nameFr; d.nameAr = nameAr; d.type = type.toUpper(); d.tone = tone; d.baseServings = baseServings;
    updateDish(d);
}

void DishModel::deleteDish(int dishId) {
    QSqlQuery q;

    // 1. Entrées du planning hebdomadaire (FK sans CASCADE)
    q.prepare("DELETE FROM WeeklyPlanning WHERE dishId=?");
    q.addBindValue(dishId);
    if (!q.exec()) qWarning() << "deleteDish/planning:" << q.lastError().text();

    // 2. Ingrédients du plat (FK avec CASCADE mais on le fait explicitement)
    q.prepare("DELETE FROM DishIngredientCrossRef WHERE dishId=?");
    q.addBindValue(dishId);
    if (!q.exec()) qWarning() << "deleteDish/crossref:" << q.lastError().text();

    // 3. Le plat lui-même
    q.prepare("DELETE FROM Dish WHERE dishId=?");
    q.addBindValue(dishId);
    if (!q.exec()) { qWarning() << "deleteDish:" << q.lastError().text(); return; }

    removeDish(dishId);
}
