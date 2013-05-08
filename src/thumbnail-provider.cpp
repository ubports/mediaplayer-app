/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include "thumbnail-provider.h"
#include "thumbnail-pipeline-gst.h"

#include <QtCore/QStringList>
#include <QtCore/QTimer>
#include <QtCore/QMutex>
#include <QtCore/QMutexLocker>
#include <QtCore/QCoreApplication>
#include <QtMultimedia/QVideoRendererControl>
#include <QtMultimedia/QMediaService>


ThumbnailProvider::ThumbnailProvider()
    : QObject(0),
      QQuickImageProvider(QQuickImageProvider::Image),
      m_player(0)
{
    connect(qApp, SIGNAL(aboutToQuit()), this, SLOT(applicationAboutToQuit()), Qt::DirectConnection);
    createPlayer();
}

ThumbnailProvider::~ThumbnailProvider()
{
    if (m_player) {
        QMutexLocker locker(&m_mutex);
        delete m_player;
        m_player = 0;
    }
}

void ThumbnailProvider::createPlayer()
{
    m_player = new ThumbnailPipeline();
}

void ThumbnailProvider::applicationAboutToQuit()
{
    QMutexLocker locker(&m_mutex);
    delete m_player;
    m_player = 0;
}

QString ThumbnailProvider::parseThumbnailName(const QString &id, qint64 *time) const
{
    QStringList data = id.split("/");
    if (data.count() < 2) {
        return "";
    }

    bool ok;
    *time = data.takeLast().toInt(&ok, 10);
    if (ok) {
        return data.join("/");
    } else {
        *time = 0;
        return "";
    }
}

QImage ThumbnailProvider::requestImage (const QString &id, QSize *size, const QSize &requestedSize)
{
    qint64 time;
    QString uri = parseThumbnailName(id, &time);

    if (uri.isEmpty()) {
        qWarning() << "Invalid url:" << id;
        return QImage();        
    }

    // check if the player exists ( the application still running )
    if (!m_player) {
        return QImage();
    }

    QMutexLocker locker(&m_mutex);

    // again check if the player exits after lock the mutex
    if (!m_player) {
        return QImage();
    }

    if (uri != m_player->uri()) {
        m_player->setUri(uri);
        m_cache.clear();
    }

    QImage img;
    if (m_cache.contains(time)) {
        img = m_cache[time];
    } else {
        img = m_player->request(time, requestedSize).copy();
        if (!img.isNull()) {
            m_cache.insert(time, img);
        }
    }

    *size = img.size();
    return img;
}
