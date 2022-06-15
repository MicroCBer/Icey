#ifndef CTX_H
#define CTX_H

#include <QObject>
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <private/qzipwriter_p.h>
#include <private/qzipreader_p.h>
#ifdef ANDROID
#include <QtAndroidExtras>
#endif
class ctx : public QObject
{
    Q_OBJECT
public:
    ctx(QObject *parent = nullptr){};
public slots:
    QString unzip(QString path)
    {
        if(!requestPermission())return "";
        QZipReader reader(path);
        QStringList fn=path.split(".");
        fn.pop_back();
        QString tofile=fn.join(".");
        QDir(tofile).mkpath(".");
        reader.extractAll(tofile);
        return tofile;
    }
    bool write(const QString& source, const QString& data)
    {
        if(requestPermission()){
            if (source.isEmpty())
                return false;
            QFile file(source);
            qDebug()<<file.exists();
            if (!file.open(QFile::WriteOnly | QFile::Truncate))
                return false;
            qDebug()<<"Opened";
            QTextStream out(&file);
            out << data;
            file.close();
            return true;
        }
        return false;
    }
    bool remove(const QString& source){
        if(requestPermission()){
            if (source.isEmpty())
                return false;
            QFile file(source);
            file.remove();
            return true;
        }
    }
    QString read(const QString& source){
        if(requestPermission()){
            if (source.isEmpty())
                return "";
            QFile file(source);
            qDebug()<<file.exists();
            file.open(QFile::ReadOnly);
            return QString(file.readAll());
        }
        return "";
    }
    bool exists(const QString& source){
        if (source.isEmpty())return false;
        QFile file(source);
        if(requestPermission())return file.exists();
        return false;
    }
    QList<QString> dir(const QString& source){
        QList<QString> empty;
        if (source.isEmpty())return empty;
        QDir dir(source);
        if(requestPermission())return dir.entryList();
//        dir.
        return empty;
    }
    void copy(const QString& from,const QString& to){
        QFile(from).copy(to);
    }
    void move(const QString& from,const QString& to){
        QFile(from).copy(to);
        QFile(from).remove();
    }
    bool renameDir(QString d, const QString & newName) {
      QDir dir(d);
      auto src = QDir::cleanPath(dir.filePath("."));
      auto dst = QDir::cleanPath(
        dir.filePath(QStringLiteral("..%1%2").arg(QDir::separator()).arg(newName)));
      auto rc = QFile::rename(src, dst);
      if (rc) dir.setPath(dst);
      return rc;
    }
signals:

private:

    bool requestPermission()
    {
        #ifdef ANDROID
        QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        if(r == QtAndroid::PermissionResult::Denied) {
            QtAndroid::requestPermissionsSync(QStringList()<<"android.permission.WRITE_EXTERNAL_STORAGE");
            r = QtAndroid::checkPermission("android.permission.CAMERA");
            if(r == QtAndroid::PermissionResult::Denied) {
                return false;
            }
        }
#endif
        return true;
    }
};

#endif // CTX_H
