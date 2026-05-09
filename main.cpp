#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QVariantMap>
#include <QDebug>
#include <QFontDatabase>
#include "src/models/DatabaseManager.h"
#include "src/models/DishModel.h"
#include "src/models/IngredientModel.h"
#include "src/models/WeeklyPlanningModel.h"
#include "src/models/ShoppingListModel.h"
#include "src/helpers/AppTheme.h"
#include "src/helpers/AppI18n.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // ── Font registration (before QML engine) ─────────────────────────────────
    const QStringList fontFiles = {
        // Instrument Serif — Latin / French serif
        ":/fonts/InstrumentSerif-Regular.ttf", ":/fonts/InstrumentSerif-Italic.ttf",
        // Manrope — Latin / French UI
        ":/fonts/Manrope-ExtraLight.ttf", ":/fonts/Manrope-Light.ttf",
        ":/fonts/Manrope-Regular.ttf",    ":/fonts/Manrope-Medium.ttf",
        ":/fonts/Manrope-SemiBold.ttf",   ":/fonts/Manrope-Bold.ttf",
        ":/fonts/Manrope-ExtraBold.ttf",
        // Tajawal — Arabic UI
        ":/fonts/Tajawal-ExtraLight.ttf", ":/fonts/Tajawal-Light.ttf",
        ":/fonts/Tajawal-Regular.ttf",    ":/fonts/Tajawal-Medium.ttf",
        ":/fonts/Tajawal-Bold.ttf",       ":/fonts/Tajawal-ExtraBold.ttf",
        ":/fonts/Tajawal-Black.ttf",
        // Noto Naskh Arabic — accent elements
        ":/fonts/NotoNaskhArabic-Regular.ttf", ":/fonts/NotoNaskhArabic-Medium.ttf",
        ":/fonts/NotoNaskhArabic-SemiBold.ttf",":/fonts/NotoNaskhArabic-Bold.ttf",
        // Aref Ruqaa — brand / titles in Arabic
        ":/fonts/ArefRuqaa-Regular.ttf", ":/fonts/ArefRuqaa-Bold.ttf",
        // JetBrains Mono — monospace / week range
        ":/fonts/JetBrainsMono-Thin.ttf",       ":/fonts/JetBrainsMono-ExtraLight.ttf",
        ":/fonts/JetBrainsMono-Light.ttf",       ":/fonts/JetBrainsMono-Regular.ttf",
        ":/fonts/JetBrainsMono-Medium.ttf",      ":/fonts/JetBrainsMono-SemiBold.ttf",
        ":/fonts/JetBrainsMono-Bold.ttf",        ":/fonts/JetBrainsMono-ExtraBold.ttf",
        ":/fonts/JetBrainsMono-Italic.ttf",      ":/fonts/JetBrainsMono-MediumItalic.ttf",
        ":/fonts/JetBrainsMono-BoldItalic.ttf",
    };
    for (const QString& path : fontFiles) {
        if (QFontDatabase::addApplicationFont(path) == -1)
            qWarning() << "Failed to load font:" << path;
    }

    if (!DatabaseManager::instance().initDb()) {
        qWarning() << "Failed to initialize database";
        return -1;
    }
    
    DishModel::instance().loadFromDatabase();
    IngredientModel::instance().loadFromDatabase();
    WeeklyPlanningModel::instance().loadForCurrentWeek();
    ShoppingListModel::instance().generateForCurrentWeek();

    QQmlApplicationEngine engine;

    // ── C++ context properties (reliable alternative to QML pragma Singleton) ──
    AppTheme theme;
    AppI18n  i18n;
    engine.rootContext()->setContextProperty("Theme",      &theme);
    engine.rootContext()->setContextProperty("I18n",       &i18n);

    // Constants as a flat QVariantMap
    QVariantMap constants {
        {"iconSizeXs", 8},  {"iconSizeSm", 14}, {"iconSizeMd", 15},
        {"iconSizeLg", 20}, {"iconSizeXl", 24},
        {"animationFast", 150}, {"animationNormal", 300}, {"animationSlow", 500},
        {"paddingHeader", 20},  {"paddingCard", 12},
        {"paddingSheet", 18},   {"paddingInput", 14},
        {"maxMobileWidth", 600}
    };
    engine.rootContext()->setContextProperty("Constants", QVariant::fromValue(constants));

    // ── Data models ────────────────────────────────────────────────────────────
    engine.rootContext()->setContextProperty("dbManager",          &DatabaseManager::instance());
    engine.rootContext()->setContextProperty("dishModel",          &DishModel::instance());
    engine.rootContext()->setContextProperty("ingredientModel",    &IngredientModel::instance());
    engine.rootContext()->setContextProperty("weeklyPlanningModel",&WeeklyPlanningModel::instance());
    engine.rootContext()->setContextProperty("shoppingListModel",  &ShoppingListModel::instance());

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app,    []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("DbaretSayda", "Main");
    return QCoreApplication::exec();
}
