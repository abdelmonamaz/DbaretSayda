#include "AppTheme.h"

AppTheme::AppTheme(QObject* parent) : QObject(parent)
{
    buildColors();
    buildSizes();
}

void AppTheme::buildColors()
{
    m_colors["bone"]  = "#FBF7F1";
    m_colors["bone2"] = "#F4EEE4";
    m_colors["card"]  = "#FFFFFF";
    m_colors["ink"]   = "#1B1714";
    m_colors["ink2"]  = "#5A5048";
    m_colors["ink3"]  = "#9A8F84";
    m_colors["line"]  = "#1A1B1714";

    m_colors["harissa"]  = QVariantMap{{"main","#E75C3A"},{"soft","#F2B8A8"},{"deep","#BA2E17"}};
    m_colors["rose"]     = QVariantMap{{"main","#E57094"},{"soft","#FAD5DF"},{"deep","#B84562"}};
    m_colors["saffron"]  = QVariantMap{{"main","#E0C660"},{"soft","#F0DFA8"},{"deep","#C9A930"}};
    m_colors["olive"]    = QVariantMap{{"main","#7BA65C"},{"soft","#A8CC92"},{"deep","#5A7A3F"}};
    m_colors["tunis"]    = QVariantMap{{"main","#5B94D0"},{"soft","#A8C8E8"},{"deep","#3F6BA0"}};
    m_colors["makroudh"] = QVariantMap{{"main","#C79B5E"},{"soft","#E3C39A"},{"deep","#9E6D34"}};
    m_colors["mint"]     = QVariantMap{{"main","#6FC8B0"},{"soft","#A8E0D5"},{"deep","#459078"}};
    m_colors["cream"]    = QVariantMap{{"main","#E9D9C3"},{"soft","#F4E9E0"},{"deep","#D1B894"}};
}

void AppTheme::buildSizes()
{
    m_sizes["xs"]  = 4;
    m_sizes["sm"]  = 6;
    m_sizes["md"]  = 8;
    m_sizes["lg"]  = 12;
    m_sizes["xl"]  = 18;
    m_sizes["xxl"] = 24;

    m_sizes["radius"] = QVariantMap{
        {"xs",4},{"sm",7},{"md",8},{"lg",12},
        {"xl",14},{"xxl",18},{"xxxl",22},{"pill",999}
    };

    m_sizes["componentSm"] = 24;
    m_sizes["componentMd"] = 32;
    m_sizes["componentLg"] = 40;
    m_sizes["componentXl"] = 48;
    m_sizes["dishThumb"]   = 56;
    m_sizes["swatch"]      = 30;
}

QVariantMap AppTheme::colors() const { return m_colors; }
QVariantMap AppTheme::sizes()  const { return m_sizes;  }

QVariantMap AppTheme::typography() const
{
    bool ar = (m_language == "ar");
    return {
        {"fontUI",       ar ? "Tajawal"    : "Manrope"},
        {"fontSerif",    ar ? "Aref Ruqaa" : "Instrument Serif"},
        {"fontMono",     "JetBrains Mono"},
        {"headerSize",   30},
        {"dayLabelSize", 22},
        {"buttonSize",   ar ? 15 : 14},
        {"tagSize",      ar ? 11 : 10},
        {"monoSize",     10},
        {"dishLabelSize",ar ?  8 :  7},
        {"inputSize",    ar ? 19 : 18}
    };
}

QStringList AppTheme::toneNames() const
{
    return {"harissa","saffron","olive","tunis","makroudh","mint","cream"};
}

void AppTheme::setLanguage(const QString& lang)
{
    if (m_language == lang) return;
    m_language = lang;
    emit languageChanged();
    emit typographyChanged();
}

QVariantMap AppTheme::getTone(const QString& name) const
{
    if (m_colors.contains(name) && m_colors[name].userType() == QMetaType::QVariantMap)
        return m_colors[name].toMap();
    return m_colors["harissa"].toMap();
}
