#pragma once
#include <QObject>
#include <QVariantMap>
#include <QStringList>

class AppTheme : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantMap  colors     READ colors     CONSTANT)
    Q_PROPERTY(QVariantMap  sizes      READ sizes      CONSTANT)
    Q_PROPERTY(QVariantMap  typography READ typography NOTIFY typographyChanged)
    Q_PROPERTY(QString      language   READ language   WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QStringList  toneNames  READ toneNames  CONSTANT)

public:
    explicit AppTheme(QObject* parent = nullptr);

    QVariantMap  colors()     const;
    QVariantMap  sizes()      const;
    QVariantMap  typography() const;
    QString      language()   const { return m_language; }
    QStringList  toneNames()  const;

    void setLanguage(const QString& lang);

    Q_INVOKABLE QVariantMap getTone(const QString& name) const;

signals:
    void languageChanged();
    void typographyChanged();

private:
    QString     m_language { "fr" };
    QVariantMap m_colors;
    QVariantMap m_sizes;

    void buildColors();
    void buildSizes();
};
