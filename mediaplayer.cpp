#include "mediaplayer.h"

#include <QtCore/QDir>
#include <QtCore/QUrl>
#include <QtCore/QDebug>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QTimer>
#include <QQmlContext>
#include <QtQuick/QQuickItem>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusReply>
#include <QtDBus/QDBusConnectionInterface>
#include "config.h"

static void printUsage(const QStringList& arguments)
{
    qDebug() << "usage:"
             << arguments.at(0).toUtf8().constData() << "[options] uri";
    qDebug();
    qDebug() << "options:";
    qDebug() << "\t-w --windowed: start windowed";
}

MediaPlayer::MediaPlayer(int &argc, char **argv)
    : QGuiApplication(argc, argv), m_view(0)
{
}

bool MediaPlayer::setup()
{
    QStringList args = arguments();
    bool windowed = args.removeAll("-w") + args.removeAll("--windowed") > 0;

    if (args.length() != 2) {
        printUsage(arguments());
        return false;
    }

    m_view = new QQuickView();
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    m_view->setWindowTitle("Media Player");
    m_view->rootContext()->setContextProperty("application", this);
    QUrl uri(QUrl::fromLocalFile(args.back()));
    m_view->rootContext()->setContextProperty("playUri", uri);
    QUrl source(mediaPlayerDirectory() + "/qml/player.qml");
    m_view->setSource(source);
    if (windowed) {
        m_view->showNormal();
    } else {
        m_view->showFullScreen();
    }

    return true;
}

MediaPlayer::~MediaPlayer()
{
    if (m_view) {
        delete m_view;
    }
}

void
MediaPlayer::toggleFullscreen()
{
    if (m_view->windowState() == Qt::WindowFullScreen) {
        m_view->setWindowState(Qt::WindowNoState);
    } else {
        m_view->setWindowState(Qt::WindowFullScreen);
    }
}
