cmake_minimum_required(VERSION 3.16)

project(DbaretSayda VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Sql QuickDialogs2)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appDbaretSayda
    main.cpp
    src/models/DatabaseManager.h
    src/models/DatabaseManager.cpp
    src/models/DishModel.h
    src/models/DishModel.cpp
    src/models/IngredientModel.h
    src/models/IngredientModel.cpp
    src/models/WeeklyPlanningModel.h
    src/models/WeeklyPlanningModel.cpp
    src/models/ShoppingListModel.h
    src/models/ShoppingListModel.cpp
    src/helpers/AppTheme.h
    src/helpers/AppTheme.cpp
    src/helpers/AppI18n.h
    src/helpers/AppI18n.cpp
)

qt_add_qml_module(appDbaretSayda
    URI DbaretSayda
    QML_FILES
        Main.qml
        qml/pages/HomePage.qml
        qml/pages/DishesPage.qml
        qml/pages/ShoppingListPage.qml
        qml/pages/SettingsPage.qml
        qml/components/PeopleStepper.qml
        qml/components/ToneSwatch.qml
        qml/components/CatPicker.qml
        qml/components/DishThumb.qml
        qml/components/Slot.qml
        qml/components/AppHeader.qml
        qml/components/BottomNav.qml
        qml/components/DayCard.qml
        qml/components/FilterChips.qml
        qml/components/IngredientPickerSheet.qml
        qml/components/IngredientDBSheet.qml
        qml/components/DishModal.qml
        qml/components/DishEditorSheet.qml
        qml/controls/ButtonDS.qml
        qml/controls/TextField.qml
        qml/controls/SearchBar.qml
        qml/controls/IconButton.qml
        qml/controls/NavIcon.qml
        qml/controls/ServingsToggle.qml
)

qt_add_resources(appDbaretSayda "appData"
    PREFIX "/db"
    BASE   "db"
    FILES
        db/schema.sql
)

qt_add_resources(appDbaretSayda "appIcons"
    PREFIX "/"
    BASE   "assets"
    FILES
        assets/icons/calendar-blank.svg
        assets/icons/chef-hat.svg
        assets/icons/card-checklist.svg
        assets/icons/settings.svg
        assets/icons/users.svg
        assets/icons/soup-bowl.svg
        assets/icons/dish.svg
        assets/icons/cake-3-line.svg
        assets/icons/refresh.svg
        assets/icons/search.svg
        assets/icons/database.svg
        assets/icons/trash.svg
)

qt_add_resources(appDbaretSayda "appFonts"
    PREFIX "/"
    BASE   "assets"
    FILES
        assets/fonts/InstrumentSerif-Regular.ttf
        assets/fonts/InstrumentSerif-Italic.ttf
        assets/fonts/Manrope-ExtraLight.ttf
        assets/fonts/Manrope-Light.ttf
        assets/fonts/Manrope-Regular.ttf
        assets/fonts/Manrope-Medium.ttf
        assets/fonts/Manrope-SemiBold.ttf
        assets/fonts/Manrope-Bold.ttf
        assets/fonts/Manrope-ExtraBold.ttf
        assets/fonts/Tajawal-ExtraLight.ttf
        assets/fonts/Tajawal-Light.ttf
        assets/fonts/Tajawal-Regular.ttf
        assets/fonts/Tajawal-Medium.ttf
        assets/fonts/Tajawal-Bold.ttf
        assets/fonts/Tajawal-ExtraBold.ttf
        assets/fonts/Tajawal-Black.ttf
        assets/fonts/NotoNaskhArabic-Regular.ttf
        assets/fonts/NotoNaskhArabic-Medium.ttf
        assets/fonts/NotoNaskhArabic-SemiBold.ttf
        assets/fonts/NotoNaskhArabic-Bold.ttf
        assets/fonts/ArefRuqaa-Regular.ttf
        assets/fonts/ArefRuqaa-Bold.ttf
        assets/fonts/JetBrainsMono-Thin.ttf
        assets/fonts/JetBrainsMono-ExtraLight.ttf
        assets/fonts/JetBrainsMono-Light.ttf
        assets/fonts/JetBrainsMono-Regular.ttf
        assets/fonts/JetBrainsMono-Medium.ttf
        assets/fonts/JetBrainsMono-SemiBold.ttf
        assets/fonts/JetBrainsMono-Bold.ttf
        assets/fonts/JetBrainsMono-ExtraBold.ttf
        assets/fonts/JetBrainsMono-Italic.ttf
        assets/fonts/JetBrainsMono-MediumItalic.ttf
        assets/fonts/JetBrainsMono-BoldItalic.ttf
)

set_target_properties(appDbaretSayda PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

target_link_libraries(appDbaretSayda
    PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::Sql Qt6::QuickDialogs2
)

target_include_directories(appDbaretSayda PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/models
    ${CMAKE_CURRENT_SOURCE_DIR}/src/helpers
)

install(TARGETS appDbaretSayda
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
