#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "ctx.h"
#include "QQmlContext"
#include <QtWebView>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    QtWebView::initialize();
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    ctx x;
    engine.rootContext()->setContextProperty("ctx",&x);
    engine.load(url);

    return app.exec();
}
