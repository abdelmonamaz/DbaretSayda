#include "AppI18n.h"

AppI18n::AppI18n(QObject* parent) : QObject(parent) { buildTranslations(); }

void AppI18n::buildTranslations()
{
    m_fr["app"]   = QVariantMap{{"title","Dbaret Sayda"},{"subtitle","Planificateur de Recettes"}};
    m_fr["brand"] = QVariantMap{{"top","Dbaret"},{"bottom","Sayda"}};
    m_fr["menu"] = QVariantMap{{"home","Accueil"},{"dishes","Mes Plats"},
                               {"shopping","Courses"},{"settings","Paramètres"}};
    m_fr["home"] = QVariantMap{
        {"title","Planning Hebdomadaire"},{"weekLabel","Semaine"},{"today","Aujourd'hui"},
        {"monday","Lundi"},{"tuesday","Mardi"},{"wednesday","Mercredi"},
        {"thursday","Jeudi"},{"friday","Vendredi"},{"saturday","Samedi"},{"sunday","Dimanche"}};
    m_fr["dishes"] = QVariantMap{
        {"title","Mes Plats"},{"newDish","Nouveau Plat"},{"editDish","Modifier le plat"},
        {"count","plats"},{"unit","plats"},{"catLabel","catégories"},{"ingr","ingr."},
        {"search","Rechercher un plat…"},
        {"nameFr","Nom (français)"},{"nameAr","Nom (arabe)"},
        {"category","Catégorie"},{"color","Couleur"},{"ingredients","Ingrédients"},
        {"noIngredient","Aucun ingrédient sélectionné"},
        {"addIngredient","Ajouter des ingrédients"},
        {"baseServings","Portions de base"},
        {"confirmDelete","Supprimer ce plat ?"},
        {"categories", QVariantMap{{"starter","Entrées"},{"main","Plats"},{"dessert","Desserts"}}}};
    m_fr["shopping"] = QVariantMap{
        {"title","Liste de Courses"},{"week","Semaine"},
        {"emptyHint","Aucune course planifiée — appuyez sur « Générer le menu »"},
        {"categories", QVariantMap{
            {"vegetables","Légumes & Fruits"},{"spices","Épices & Bocaux"},
            {"meat","Viandes & Poissons"},{"liquid","Liquides"},
            {"pastry","Pâtisseries"},{"other","Autres"}}}};
    m_fr["settings"] = QVariantMap{
        {"title","Paramètres"},{"language","Langue"},{"french","Français"},{"arabic","العربية"}};
    m_fr["button"] = QVariantMap{
        {"save","Enregistrer"},{"delete","Supprimer"},{"cancel","Annuler"},{"no","Non"},
        {"add","Ajouter"},{"edit","Modifier"},{"close","Fermer"}};
    m_fr["message"] = QVariantMap{{"servings","personnes"},{"portions","portions"}};
    m_fr["header"]  = QVariantMap{{"weekRange","pour toute la semaine"},{"generate","Générer le menu"}};
    m_fr["tabs"]    = QVariantMap{{"planner","Menu"},{"dishes","Mes plats"},{"shopping","Courses"},{"settings","Paramètres"}};
    m_fr["filter"]      = QVariantMap{{"planned","prévus"},{"days","jours"}};
    m_fr["ingredients"] = QVariantMap{
        {"pickTitle","Choisir des ingrédients"},{"manageBase","Gérer la base"},
        {"search","Rechercher un ingrédient…"},{"all","Tout"},{"done","Terminé"},
        {"dbTitle","Base d'ingrédients"},{"newIngredient","+ Nouvel ingrédient"},
        {"editTitle","Modifier l'ingrédient"},{"unitLabel","Unité"},
        {"units", QVariantMap{
            {"GR","g"},{"KG","kg"},{"ML","ml"},{"L","L"},
            {"PIECE","pcs"},{"CAS","c.à.s"},{"CAC","c.à.c"}}}};

    m_ar["app"]   = QVariantMap{{"title","دبارة سيّدة"},{"subtitle","منظم الوصفات"}};
    m_ar["brand"] = QVariantMap{{"top","دبارة"},{"bottom","سيّدة"}};
    m_ar["menu"] = QVariantMap{{"home","الرئيسية"},{"dishes","وصفاتي"},
                               {"shopping","قائمة التسوق"},{"settings","الإعدادات"}};
    m_ar["home"] = QVariantMap{
        {"title","التخطيط الأسبوعي"},{"weekLabel","الأسبوع"},{"today","اليوم"},
        {"monday","الاثنين"},{"tuesday","الثلاثاء"},{"wednesday","الأربعاء"},
        {"thursday","الخميس"},{"friday","الجمعة"},{"saturday","السبت"},{"sunday","الأحد"}};
    m_ar["dishes"] = QVariantMap{
        {"title","أطباقي"},{"newDish","طبق جديد"},{"editDish","تعديل الطبق"},
        {"count","طبق"},{"unit","طبق"},{"catLabel","فئات"},{"ingr","مكون"},
        {"search","البحث عن طبق…"},
        {"nameFr","الاسم (فرنسي)"},{"nameAr","الاسم (عربي)"},
        {"category","الفئة"},{"color","اللون"},{"ingredients","المكونات"},
        {"noIngredient","لا توجد مكونات مختارة"},
        {"addIngredient","إضافة مكونات"},
        {"baseServings","الحصص الأساسية"},
        {"confirmDelete","حذف هذا الطبق؟"},
        {"categories", QVariantMap{{"starter","المقبلات"},{"main","الرئيسية"},{"dessert","الحلويات"}}}};
    m_ar["shopping"] = QVariantMap{
        {"title","قائمة التسوق"},{"week","الأسبوع"},
        {"emptyHint","لا توجد مشتريات — اضغط على «حضّر منيو الأسبوع»"},
        {"categories", QVariantMap{
            {"vegetables","الخضار والفواكه"},{"spices","التوابل والمعلبات"},
            {"meat","اللحوم والأسماك"},{"liquid","السوائل"},
            {"pastry","الحلويات والعجائن"},{"other","أخرى"}}}};
    m_ar["settings"] = QVariantMap{
        {"title","الإعدادات"},{"language","اللغة"},{"french","Français"},{"arabic","العربية"}};
    m_ar["button"] = QVariantMap{
        {"save","حفظ"},{"delete","حذف"},{"cancel","إلغاء"},{"no","لا"},
        {"add","إضافة"},{"edit","تعديل"},{"close","إغلاق"}};
    m_ar["message"] = QVariantMap{{"servings","أشخاص"},{"portions","حصص"}};
    m_ar["header"]  = QVariantMap{{"weekRange","للأسبوع الكامل"},{"generate","حضّر منيو الأسبوع"}};
    m_ar["tabs"]    = QVariantMap{{"planner","المنيو"},{"dishes","أطباقي"},{"shopping","المشتريات"},{"settings","الإعدادات"}};
    m_ar["filter"]      = QVariantMap{{"planned","مقرر"},{"days","أيّام"}};
    m_ar["ingredients"] = QVariantMap{
        {"pickTitle","اختيار المكونات"},{"manageBase","إدارة القاعدة"},
        {"search","البحث عن مكون…"},{"all","الكل"},{"done","تم"},
        {"dbTitle","قاعدة المكونات"},{"newIngredient","+ مكون جديد"},
        {"editTitle","تعديل المكون"},{"unitLabel","الوحدة"},
        {"units", QVariantMap{
            {"GR","غ"},{"KG","كغ"},{"ML","مل"},{"L","ل"},
            {"PIECE","حبة"},{"CAS","م.ك"},{"CAC","م.ص"}}}};
}

QString AppI18n::resolve(const QVariantMap& dict, const QString& key) const
{
    const QStringList parts = key.split('.');
    QVariant current        = dict;
    for (const QString& part : parts) {
        if (current.userType() != QMetaType::QVariantMap) return key;
        QVariantMap map = current.toMap();
        if (!map.contains(part)) return key;
        current = map.value(part);
    }
    return current.toString();
}

QString AppI18n::t(const QString& key) const
{
    return resolve(m_lang.value() == "ar" ? m_ar : m_fr, key);
}

void AppI18n::setLanguage(const QString& lang)
{
    if (m_lang.value() == lang || (lang != "fr" && lang != "ar")) return;
    m_lang.setValue(lang);   // Q_OBJECT_BINDABLE_PROPERTY emits currentLanguageChanged automatically
}

QString AppI18n::formatNumber(int num) const
{
    if (m_lang.value() != "ar") return QString::number(num);
    const QString d = "٠١٢٣٤٥٦٧٨٩";
    QString out;
    for (const QChar c : QString::number(num))
        out += c.isDigit() ? d[c.digitValue()] : c;
    return out;
}
