#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>

class DatabaseManager : public QObject {
    Q_OBJECT

public:
    static DatabaseManager& instance();
    
    bool initDb();
    bool isInitialized() const { return m_initialized; }
    QSqlDatabase getDatabase() const { return m_database; }

    Q_INVOKABLE QString exportDbTo(const QString& destUrl) const;
    Q_INVOKABLE QString defaultExportFolder() const;
    Q_INVOKABLE bool    importDb(const QString& srcUrl);

private:
    DatabaseManager();
    ~DatabaseManager();
    
    bool applySchema();
    
    QSqlDatabase m_database;
    bool m_initialized;
    
    static DatabaseManager* s_instance;
};

#endif // DATABASEMANAGER_H
