# Ftour Jomaa — دبرة صيدا

A Tunisian meal planner for Android (and Desktop), built with **Qt 6 / QML + C++** and a local **SQLite** database.

---

## Features

- **Random weekly menu** — generate a full 7-day plan at the tap of a button; choose which meal types to include (starter / main / dessert)
- **Servings selector** — adjust the number of people; all ingredient quantities scale automatically
- **Shopping list** — auto-aggregated from the weekly plan, grouped and deduplicated across days
- **Dish library** — browse, search, add, edit and delete dishes with their full ingredient lists
- **Ingredient database** — manage the shared ingredient library (name, Arabic name, category, default unit)
- **Bilingual** — French and Arabic throughout (UI strings + ingredient/dish names)

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Qt 6 QML + Qt Quick Controls 2 |
| Business logic | C++ (Qt 6 models) |
| Database | SQLite via `Qt Sql` |
| Build system | CMake 3.16 + `qt_standard_project_setup` |
| Targets | Android, Windows Desktop |

---

## Project Structure

```
ftour_jomaa/
├── main.cpp
├── Main.qml
├── CMakeLists.txt
│
├── src/
│   ├── models/
│   │   ├── DatabaseManager      # DB init, seed & queries
│   │   ├── DishModel            # Dish CRUD + filtering
│   │   ├── IngredientModel      # Ingredient library CRUD
│   │   ├── WeeklyPlanningModel  # Random plan generation & editing
│   │   └── ShoppingListModel    # Aggregated shopping list
│   └── helpers/
│       ├── AppTheme             # Colour tokens & typography
│       └── AppI18n              # Runtime language switching (fr / ar)
│
├── qml/
│   ├── pages/
│   │   ├── HomePage.qml
│   │   ├── DishesPage.qml
│   │   ├── ShoppingListPage.qml
│   │   └── SettingsPage.qml
│   ├── components/              # DayCard, DishThumb, DishModal, etc.
│   └── controls/                # ButtonDS, TextField, SearchBar, etc.
│
├── db/
│   └── schema.sql               # Generated seed — DO NOT edit by hand
│
├── tools/
│   └── gen_schema.py            # Regenerates schema.sql from JSON source
│
└── assets/
    ├── icons/
    └── fonts/                   # Manrope, Tajawal, NotoNaskh Arabic, …
```

---

## Database Schema

```
Dish               — dishId, name, nameAr, type (STARTER|MAIN|DESSERT), tone, imageUri, baseServings
IngredientLibrary  — ingredientId, name, nameAr, category, defaultUnit
DishIngredientCrossRef — dishId × ingredientId × quantity
WeeklyPlanning     — planId, weekId, dayId (0–6), dishId, plannedServings, mealType
```

Ingredient categories: `VEGETABLE · SPICE · MEAT · LIQUID · PASTRY · OTHER`

The database is seeded on first launch from the embedded `:/db/schema.sql` resource (105 Tunisian dishes, 152 unique ingredients).

---

## Building

### Prerequisites

- Qt 6.10+ with components: `Core Gui Qml Quick Sql QuickDialogs2`
- CMake 3.16+
- Android NDK + SDK (for Android builds) or MSVC 2022 (for Windows)

### Android

Configure the Android kit in Qt Creator and build via the IDE, or use `cmake` with the Android toolchain file.

---

## Reseeding the Database

To reset all data to the bundled defaults, delete the app's `.db` file (located in `QStandardPaths::AppDataLocation`) and relaunch the application.

---

## License

Personal / private project. All rights reserved.
