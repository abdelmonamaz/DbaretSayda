# Dbaret Sayda - دبارة سيدة

A Tunisian meal planner for Android (and Desktop), built with **Qt 6 / QML + C++** and a local **SQLite** database.

> Answer the timeless question: *"Qu'est-ce qu'on mange cette semaine ?"* — before heading to the grocery store.

---

## Screenshots

<p align="center">
  <img width="476" height="965" alt="Home" src="https://github.com/user-attachments/assets/a817f873-87cc-4653-af96-a52e33f23ee8" />
  <img width="467" height="965" alt="Dishes" src="https://github.com/user-attachments/assets/cebfdd86-268e-44e1-bc2d-97907088f915" />
  <img width="487" height="968" alt="Shopping list" src="https://github.com/user-attachments/assets/2ea18a4a-afa4-452e-81ee-2516bda49d39" />
  <img width="477" height="962" alt="Settings" src="https://github.com/user-attachments/assets/f1325622-7439-41a9-9165-6abe820c4941" />
</p>

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
| UI | Qt 6 QML + Qt Quick Controls 2 + QuickDialogs2 |
| Business logic | C++ (Qt 6 models) |
| Database | SQLite via `Qt Sql` |
| Build system | CMake 3.16 + `qt_standard_project_setup` |
| Targets | Android (arm64-v8a, x86_64), Windows Desktop |

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
│   │   ├── DatabaseManager.h / .cpp      # DB init, seed on first launch & all queries
│   │   ├── DishModel.h / .cpp            # Dish list with CRUD + type filtering
│   │   ├── IngredientModel.h / .cpp      # Shared ingredient library CRUD
│   │   ├── WeeklyPlanningModel.h / .cpp  # Random plan generation, day editing
│   │   └── ShoppingListModel.h / .cpp    # Aggregated & deduplicated shopping list
│   └── helpers/
│       ├── AppTheme.h / .cpp             # Colour tokens, typography, tone system
│       └── AppI18n.h / .cpp              # Runtime language switching (fr / ar)
│
├── qml/
│   ├── pages/
│   │   ├── HomePage.qml           # Weekly calendar view + random generate button
│   │   ├── DishesPage.qml         # Searchable dish library
│   │   ├── ShoppingListPage.qml   # Shopping list grouped by category
│   │   └── SettingsPage.qml       # Language, servings, meal-type toggles
│   ├── components/
│   │   ├── AppHeader.qml          # Top app bar
│   │   ├── BottomNav.qml          # Bottom navigation bar
│   │   ├── DayCard.qml            # Single day slot in the weekly plan
│   │   ├── Slot.qml               # Meal slot (starter / main / dessert)
│   │   ├── DishThumb.qml          # Dish thumbnail card
│   │   ├── DishModal.qml          # Dish detail popup
│   │   ├── DishEditorSheet.qml    # Add / edit dish bottom sheet
│   │   ├── IngredientPickerSheet.qml  # Pick ingredients for a dish
│   │   ├── IngredientDBSheet.qml      # Browse / manage ingredient library
│   │   ├── FilterChips.qml        # Dish-type filter chips
│   │   ├── CatPicker.qml          # Ingredient category picker
│   │   ├── PeopleStepper.qml      # Guest count stepper
│   │   └── ToneSwatch.qml         # Colour tone selector
│   └── controls/
│       ├── ButtonDS.qml           # Design-system button
│       ├── TextField.qml          # Styled text input
│       ├── SearchBar.qml          # Search input with clear button
│       ├── IconButton.qml         # Icon-only button
│       ├── NavIcon.qml            # Bottom-nav icon with active state
│       └── ServingsToggle.qml     # Per-dish servings toggle
│
├── db/
│   └── schema.sql                 # Generated seed — DO NOT edit by hand
│
├── assets/
│   ├── icons/                     # SVG icons (calendar, chef-hat, checklist, …)
│   └── fonts/
│       ├── Manrope (9 weights)    # Latin UI font
│       ├── Tajawal (7 weights)    # Arabic UI font
│       ├── NotoNaskhArabic (4 weights)
│       ├── InstrumentSerif (regular + italic)
│       ├── ArefRuqaa (regular + bold)
│       └── JetBrainsMono (16 variants)
```

---

## Database Schema

```sql
Dish               — dishId, name, nameAr, type (STARTER|MAIN|DESSERT),
                     tone, imageUri, baseServings
IngredientLibrary  — ingredientId, name, nameAr, category, defaultUnit
DishIngredientCrossRef — dishId × ingredientId × quantity
WeeklyPlanning     — planId, weekId, dayId (0–6), dishId,
                     plannedServings, mealType
```

**Ingredient categories:** `VEGETABLE · SPICE · MEAT · LIQUID · PASTRY · OTHER`

The database is seeded on first launch from the embedded `:/db/schema.sql` Qt resource — **105 Tunisian dishes** and **152 unique ingredients**.

---

## Building

### Prerequisites

- Qt 6.10+ with components: `Core Gui Qml Quick Sql QuickDialogs2`
- CMake 3.16+
- Android NDK + SDK (for Android builds) or MSVC 2022 (for Windows)

### Desktop (Windows)

```powershell
cmake -S . -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.10.x/msvc2022_64"
cmake --build build --config Release
```

### Android

Configure the Android kit in Qt Creator (`arm64-v8a` or `x86_64`) and build via the IDE, or use `cmake` with the Android toolchain file.

---

## Reseeding the Database

To reset all data to the bundled defaults, delete the app's `.db` file (located in `QStandardPaths::AppDataLocation`) and relaunch the application. `INSERT OR IGNORE` ensures a partial seed won't error.

---

## License

Personal / private project. All rights reserved.
