#pragma once
#include <QObject>
#include <QVariantMap>
#include <QProperty>

class AppI18n : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY currentLanguageChanged BINDABLE bindableCurrentLanguage)
    Q_PROPERTY(bool    isRtl           READ isRtl           NOTIFY currentLanguageChanged)

public:
    explicit AppI18n(QObject* parent = nullptr);

    QString            currentLanguage()          const { return m_lang.value(); }
    bool               isRtl()                   const { return m_lang.value() == "ar"; }
    QBindable<QString> bindableCurrentLanguage()        { return QBindable<QString>(&m_lang); }

    Q_INVOKABLE QString t(const QString& key)            const;
    Q_INVOKABLE void    setLanguage(const QString& lang);
    Q_INVOKABLE QString formatNumber(int num)            const;

signals:
    void currentLanguageChanged();

private:
    Q_OBJECT_BINDABLE_PROPERTY(AppI18n, QString, m_lang, &AppI18n::currentLanguageChanged)

    QVariantMap m_fr;
    QVariantMap m_ar;

    void    buildTranslations();
    QString resolve(const QVariantMap& dict, const QString& key) const;
};
