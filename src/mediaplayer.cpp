/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
 *  Michał Sawicz <michal.sawicz@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "mediaplayer.h"
#include "thumbnail-provider.h"
#include "sharefile.h"

#include <QtCore/QDir>
#include <QtCore/QUrl>
#include <QtCore/QDebug>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QLibrary>
#include <QtCore/QTimer>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
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
    qDebug() << "\t-p --portrait: start in portrait";
}

MediaPlayer::MediaPlayer(int &argc, char **argv)
    : QGuiApplication(argc, argv), m_view(0)
{
}

bool MediaPlayer::setup()
{
    QStringList args = arguments();
    bool windowed = args.removeAll("-w") + args.removeAll("--windowed") > 0;
    bool portrait = args.removeAll("-p") + args.removeAll("--portrait") > 0;
    bool testability = args.removeAll("-testability") > 0;

    // The testability driver is only loaded by QApplication but not by
    // QGuiApplication.
    // However, QApplication depends on QWidget which would add some
    // unneeded overhead => Let's load the testability driver on our own.
    if(testability) {
        QLibrary testLib(QLatin1String("qttestability"));
        if (testLib.load()) {
            typedef void (*TasInitialize)(void);
            TasInitialize initFunction =
                (TasInitialize)testLib.resolve("qt_testability_init");
            if (initFunction) {
                initFunction();
            } else {
                qCritical("Library qttestability resolve failed!");
            }
        } else {
            qCritical("Library qttestability load failed!");
        }
    }

    //TODO: move this to SDK/ShareMenu library
    qmlRegisterType<ShareFile>("SDKHelper", 1, 0, "ShareFile");

    m_view = new QQuickView();
    m_view->engine()->addImageProvider("video", new ThumbnailProvider);
    m_view->setColor(QColor("black"));
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    m_view->setTitle("Media Player");
    if (args.count() >= 2) {
        QUrl uri(QUrl::fromLocalFile(QDir::current().absoluteFilePath(args[1])));
        m_view->rootContext()->setContextProperty("playUri", uri);
    }

    m_view->rootContext()->setContextProperty("screenWidth", m_view->size().width());
    m_view->rootContext()->setContextProperty("screenHeight", m_view->size().height());
    connect(m_view, SIGNAL(widthChanged(int)), SLOT(onWidthChanged(int)));
    connect(m_view, SIGNAL(heightChanged(int)), SLOT(onHeightChanged(int)));
    connect(m_view->engine(), SIGNAL(quit()), SLOT(quit()));

    m_view->rootContext()->setContextProperty("portrait", portrait);

    QUrl source(mediaPlayerDirectory() + "/qml/player.qml");
    m_view->setSource(source);
    m_view->setWidth(1200);
    m_view->setHeight(675);
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

void
MediaPlayer::onWidthChanged(int width)
{
    m_view->rootContext()->setContextProperty("screenWidth", width);
}

void
MediaPlayer::onHeightChanged(int height)
{
    m_view->rootContext()->setContextProperty("screenHeight", height);
}
