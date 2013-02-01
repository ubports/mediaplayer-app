/*
 * This file is part of unity-2d
 *
 * Copyright 2010-2011 Canonical Ltd.
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
#include "thumbnail-pipeline.h"

#include <QtCore/QStringList>
#include <QtCore/QTimer>
#include <QtCore/QMutex>
#include <QtCore/QCoreApplication>
#include <QtMultimedia/QVideoRendererControl>
#include <QtMultimedia/QMediaService>


ThumbnailProvider::ThumbnailProvider()
    : QObject(0),
      QQuickImageProvider(QQuickImageProvider::Image),
      m_player(0)
{
    connect(qApp, SIGNAL(aboutToQuit()), this, SLOT(applicationAboutToQuit()));
    createPlayer();
}

ThumbnailProvider::~ThumbnailProvider()
{
    if (m_player) {
        delete m_player;
    }
}

void ThumbnailProvider::createPlayer()
{
    m_player = new ThumbnailPipeline(this);
}

void ThumbnailProvider::applicationAboutToQuit()
{
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

    if (uri != m_player->uri()) {
        m_player->setUri(uri);
        m_cache.clear();
    }

    QImage img;
    if (m_cache.contains(time)) {
        img = m_cache[time];
    } else {
        img = m_player->request(time).copy();
    }

    if (requestedSize.isValid()) {
        *size = requestedSize;
        return img.scaled(requestedSize);
    } else {
        *size = img.size();
        return img;
    }
}
