#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QUrl>

#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QJniEnvironment>

// Écrit un fichier local vers une URI content:// via ContentResolver (SAF Android)
static bool writeToContentUri(const QString& srcPath, const QString& contentUri)
{
    QFile src(srcPath);
    if (!src.open(QIODevice::ReadOnly)) return false;
    QByteArray data = src.readAll();
    src.close();
    if (data.isEmpty()) return false;

    QJniEnvironment env;

    QJniObject context = QJniObject::callStaticObjectMethod(
        "org/qtproject/qt/android/QtNative", "activity",
        "()Landroid/app/Activity;");
    if (!context.isValid()) return false;

    QJniObject uriStr = QJniObject::fromString(contentUri);
    QJniObject uri    = QJniObject::callStaticObjectMethod(
        "android/net/Uri", "parse",
        "(Ljava/lang/String;)Landroid/net/Uri;",
        uriStr.object<jstring>());
    if (!uri.isValid()) return false;

    QJniObject resolver = context.callObjectMethod(
        "getContentResolver", "()Landroid/content/ContentResolver;");
    if (!resolver.isValid()) return false;

    QJniObject os = resolver.callObjectMethod(
        "openOutputStream",
        "(Landroid/net/Uri;)Ljava/io/OutputStream;",
        uri.object());
    if (!os.isValid() || env->ExceptionCheck()) {
        env->ExceptionClear();
        return false;
    }

    jbyteArray arr = env->NewByteArray(data.size());
    env->SetByteArrayRegion(arr, 0, data.size(),
                            reinterpret_cast<const jbyte*>(data.constData()));
    os.callMethod<void>("write", "([B)V", arr);
    env->DeleteLocalRef(arr);

    bool ok = !env->ExceptionCheck();
    if (!ok) env->ExceptionClear();

    os.callMethod<void>("flush");
    os.callMethod<void>("close");
    return ok;
}
#endif

DatabaseManager* DatabaseManager::s_instance = nullptr;

DatabaseManager::DatabaseManager() : m_initialized(false) {}

DatabaseManager::~DatabaseManager() {}

DatabaseManager& DatabaseManager::instance() {
    if (s_instance == nullptr) {
        s_instance = new DatabaseManager();
    }
    return *s_instance;
}

bool DatabaseManager::initDb() {
    m_database = QSqlDatabase::addDatabase("QSQLITE");

    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataPath);

    QString dbPath = dataPath + "/ftour_jomaa.db";
    m_database.setDatabaseName(dbPath);

    if (!m_database.open()) {
        qWarning() << "Failed to open database:" << m_database.lastError().text();
        return false;
    }

    qDebug() << "Database opened at:" << dbPath;

    if (!applySchema()) {
        qWarning() << "Failed to apply schema";
        return false;
    }

    m_initialized = true;
    return true;
}

QString DatabaseManager::defaultExportFolder() const {
    QString path = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    if (path.isEmpty())
        path = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    return QUrl::fromLocalFile(path).toString();
}

QString DatabaseManager::exportDbTo(const QString& destUrl) const {
    // Flush WAL pour garantir un fichier cohérent
    QSqlQuery q(m_database);
    q.exec("PRAGMA wal_checkpoint(TRUNCATE)");

    const QString src = m_database.databaseName();

#ifdef Q_OS_ANDROID
    // Sur Android le FileDialog renvoie une URI content:// (SAF)
    if (destUrl.startsWith("content://")) {
        if (writeToContentUri(src, destUrl)) {
            qDebug() << "DB exported via SAF:" << destUrl;
            return destUrl;
        }
        qWarning() << "SAF export failed →" << destUrl;
        return QString();
    }
#endif

    // Desktop : chemin fichier classique
    QString destPath = QUrl(destUrl).toLocalFile();
    if (destPath.isEmpty()) destPath = destUrl;

    if (QFile::exists(destPath)) QFile::remove(destPath);
    if (QFile::copy(src, destPath)) {
        qDebug() << "DB exported to:" << destPath;
        return destPath;
    }
    qWarning() << "Export failed →" << destPath;
    return QString();
}

bool DatabaseManager::importDb(const QString& srcUrl)
{
    const QString destPath = m_database.databaseName();

    // Ferme la connexion proprement avant de remplacer le fichier
    m_database.close();

    // Sauvegarde de sécurité
    const QString backup = destPath + ".bak";
    QFile::remove(backup);
    QFile::copy(destPath, backup);

    // Supprime aussi les fichiers WAL/SHM qui pourraient être incohérents
    QFile::remove(destPath + "-wal");
    QFile::remove(destPath + "-shm");
    QFile::remove(destPath);

    bool copied = false;

#ifdef Q_OS_ANDROID
    if (srcUrl.startsWith("content://")) {
        // Lecture via ContentResolver (SAF) → écriture locale
        QJniEnvironment env;
        QJniObject context = QJniObject::callStaticObjectMethod(
            "org/qtproject/qt/android/QtNative", "activity",
            "()Landroid/app/Activity;");

        if (context.isValid()) {
            QJniObject uriStr = QJniObject::fromString(srcUrl);
            QJniObject uri    = QJniObject::callStaticObjectMethod(
                "android/net/Uri", "parse",
                "(Ljava/lang/String;)Landroid/net/Uri;",
                uriStr.object<jstring>());

            QJniObject resolver = context.callObjectMethod(
                "getContentResolver", "()Landroid/content/ContentResolver;");

            QJniObject is = resolver.callObjectMethod(
                "openInputStream",
                "(Landroid/net/Uri;)Ljava/io/InputStream;",
                uri.object());

            if (is.isValid() && !env->ExceptionCheck()) {
                // Lit par blocs de 64 Ko
                QFile dest(destPath);
                if (dest.open(QIODevice::WriteOnly)) {
                    jbyteArray buf = env->NewByteArray(65536);
                    int n;
                    while ((n = is.callMethod<jint>("read", "([B)I", buf)) > 0) {
                        jbyte* raw = env->GetByteArrayElements(buf, nullptr);
                        dest.write(reinterpret_cast<const char*>(raw), n);
                        env->ReleaseByteArrayElements(buf, raw, JNI_ABORT);
                    }
                    env->DeleteLocalRef(buf);
                    dest.close();
                    copied = !env->ExceptionCheck();
                    if (!copied) env->ExceptionClear();
                }
                is.callMethod<void>("close");
            } else {
                env->ExceptionClear();
            }
        }
    } else
#endif
    {
        QString srcPath = QUrl(srcUrl).toLocalFile();
        if (srcPath.isEmpty()) srcPath = srcUrl;
        copied = QFile::copy(srcPath, destPath);
    }

    // Restaure la sauvegarde en cas d'échec
    if (!copied) {
        QFile::copy(backup, destPath);
        m_database.open();
        qWarning() << "importDb failed, backup restored";
        return false;
    }

    QFile::remove(backup);

    // Rouvre la connexion sur le nouveau fichier
    if (!m_database.open()) {
        qWarning() << "importDb: cannot reopen database";
        return false;
    }
    qDebug() << "DB imported from:" << srcUrl;
    return true;
}

bool DatabaseManager::applySchema() {
    QSqlQuery pragma(m_database);
    pragma.exec("PRAGMA foreign_keys = ON");
    pragma.exec("PRAGMA journal_mode = WAL");

    // Table marqueur : créée une seule fois, indique que le seed a déjà été joué
    pragma.exec("CREATE TABLE IF NOT EXISTS _seeded (id INTEGER PRIMARY KEY)");
    pragma.exec("SELECT id FROM _seeded WHERE id = 1");
    const bool alreadySeeded = pragma.next();

    QFile f(":/db/schema.sql");
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Cannot open :/db/schema.sql";
        return false;
    }

    QStringList cleanLines;
    QTextStream in(&f);
    while (!in.atEnd()) {
        QString line = in.readLine();
        if (!line.trimmed().startsWith("--"))
            cleanLines.append(line);
    }
    f.close();

    QSqlQuery q(m_database);
    for (const QString& raw : cleanLines.join('\n').split(';', Qt::SkipEmptyParts)) {
        const QString stmt = raw.trimmed();
        if (stmt.isEmpty()) continue;

        // Au-delà du premier lancement, on ne rejoue que le DDL (CREATE / INDEX)
        // et on ignore les INSERT de seed pour ne pas restaurer les données supprimées.
        const QString upper = stmt.left(10).toUpper();
        const bool isDML = upper.startsWith("INSERT") ||
                           upper.startsWith("UPDATE") ||
                           upper.startsWith("DELETE");
        if (alreadySeeded && isDML) continue;

        if (!q.exec(stmt)) {
            const QString err = q.lastError().text();
            if (!err.contains("already exists", Qt::CaseInsensitive))
                qWarning() << "SQL error:" << err << "\nStatement:" << stmt.left(80);
        }
    }

    // Marque la BDD comme seedée si c'était la première fois
    if (!alreadySeeded) {
        q.exec("INSERT OR IGNORE INTO _seeded (id) VALUES (1)");
        qDebug() << "Schema seeded for the first time";
    } else {
        qDebug() << "Schema structure updated (seed skipped)";
    }

    return true;
}
