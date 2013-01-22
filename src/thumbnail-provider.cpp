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
#include "thumbnail-surface.h"

#include <QtCore/QStringList>
#include <QtCore/QTimer>
#include <QtCore/QMutex>
#include <QtCore/QCoreApplication>
#include <QtMultimedia/QVideoRendererControl>
#include <QtMultimedia/QMediaService>

class ThumbnailRequest
{
public:
    ThumbnailRequest(qint64 time);
    ~ThumbnailRequest();
    void setImage(const QImage &frame);
    void wait();
    QImage image() const;
    qint64 time() const;

private:
    qint64 m_time;
    QImage m_image;
    QMutex m_mutex;
    bool m_exiting;
};

ThumbnailRequest::ThumbnailRequest(qint64 time)
    : m_time(time),
      m_exiting(false)
{
    m_mutex.lock();
}

ThumbnailRequest::~ThumbnailRequest()
{
    m_exiting = true;

    // unlock any active request
    setImage(QImage());

    // wait for unfinished request
    m_mutex.lock();
    m_mutex.unlock();
}

void ThumbnailRequest::setImage(const QImage &frame)
{
    m_image = frame.copy();
    m_mutex.unlock();
}

void ThumbnailRequest::wait()
{
    if (m_image.isNull()) {
        while (!m_mutex.tryLock(100)) {
            if (m_exiting) {
                return;
            }
        }
        m_mutex.unlock();
    }
}

QImage ThumbnailRequest::image() const
{
    return m_image;
}

qint64 ThumbnailRequest::time() const
{
    return m_time;
}

ThumbnailProvider::ThumbnailProvider()
    : QObject(0),
      QQuickImageProvider(QQuickImageProvider::Image),
      m_mediaLoaded(false),
      m_running(false),
      m_exiting(false)
{
    m_player = new QMediaPlayer;
    m_player->setMuted(true);
    connect(m_player, SIGNAL(mediaStatusChanged(QMediaPlayer::MediaStatus)), this, SLOT(mediaPlayerStatusChanged(QMediaPlayer::MediaStatus)));

    QVideoRendererControl* rendererControl =  m_player->service()->requestControl<QVideoRendererControl*>();
    if (rendererControl) {
        m_surface = new ThumbnailSurface;
        connect(m_surface, SIGNAL(newFrame(qint64,QImage&)), this, SLOT(updateThumbnail(qint64,QImage&)));
        rendererControl->setSurface(m_surface);
    }

    connect(qApp, SIGNAL(aboutToQuit()), this, SLOT(applicationAboutToQuit()));
}

ThumbnailProvider::~ThumbnailProvider()
{
    m_exiting = true;
    clearCache();

    if (m_player) {
        delete m_player;
    }
}

void ThumbnailProvider::applicationAboutToQuit()
{
    m_exiting = true;
    clearCache();
}

QQmlImageProviderBase::Flags ThumbnailProvider::flags() const
{
    QQmlImageProviderBase::ForceAsynchronousImageLoading;
}

void ThumbnailProvider::mediaPlayerStatusChanged(QMediaPlayer::MediaStatus status)
{
    switch (status)
    {
    case QMediaPlayer::LoadedMedia:
        m_player->pause();
        break;
    case QMediaPlayer::BufferedMedia:
        m_mediaLoaded = true;
        start();
        break;
    case QMediaPlayer::StalledMedia:
    case QMediaPlayer::InvalidMedia:
        qWarning() << "Invalid movie file";
        break;
    }
}

void ThumbnailProvider::updateThumbnail(qint64 position, QImage &frame)
{
    if (!m_mediaLoaded) {
        return;
    }

    ThumbnailRequest *request = m_requests.dequeue();
    request->setImage(frame);

    // next
    if (!m_exiting) {
        QTimer::singleShot(1, this, SLOT(getNextFrame()));
    }
}

void ThumbnailProvider::getNextFrame()
{
    if (m_requests.count() > 0) {
        m_player->setPosition(m_requests.head()->time());
    }
}

void ThumbnailProvider::clearCache()
{
    m_requests.clear();
    Q_FOREACH(ThumbnailRequest *r, m_cache.values()) {
        delete r;
    }

    m_cache.clear();
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

void ThumbnailProvider::start()
{
    if (!m_running && m_mediaLoaded && (m_requests.count() > 0)) {
        m_running = true;
        m_player->setPosition(m_requests.head()->time());
    }
}


ThumbnailRequest *ThumbnailProvider::request(qint64 time)
{
    ThumbnailRequest *r = 0;
    if (!m_cache.contains(time)) {
        r = new ThumbnailRequest(time);
        m_cache.insert(time, r);
        m_requests << r;
        start();
    } else {
        r = m_cache[time];
    }

    return r;
}

QImage ThumbnailProvider::requestImage (const QString &id, QSize *size, const QSize &requestedSize)
{
    if (m_exiting) {
        return QImage();
    }

    qint64 time;
    QString url = parseThumbnailName(id, &time);

    if (url.isEmpty()) {
        return QImage();
    }

    QUrl currentUrl = m_player->currentMedia().canonicalUrl();
    if (currentUrl != url) {
        clearCache();
        m_mediaLoaded = false;
        m_player->setMedia(QUrl(url));
    }

    ThumbnailRequest *r = request(time);
    r->wait();
    QImage img = r->image();

    if (requestedSize.isValid()) {
        *size = requestedSize;
        return img.scaled(requestedSize);
    } else {
        *size = img.size();
        return img;
    }
}
