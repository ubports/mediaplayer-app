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

#ifndef THUMBNAIL_PROVIDER_H
#define THUMBNAIL_PROVIDER_H

#include <QtQuick/QQuickImageProvider>
#include <QtMultimedia/QMediaPlayer>
#include <QtMultimedia/QVideoSurfaceFormat>
#include <QtGui/QImage>
#include <QtCore/QMap>
#include <QtCore/QQueue>

class ThumbnailRequest;
class ThumbnailSurface;

class ThumbnailProvider : public QObject, public QQuickImageProvider
{
    Q_OBJECT

    public:
        ThumbnailProvider();
        ~ThumbnailProvider();

        QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
        QQmlImageProviderBase::Flags flags() const;

    private Q_SLOTS:
        void getNextFrame();
        void updateThumbnail(qint64 position, QImage &frame);
        void mediaPlayerStatusChanged(QMediaPlayer::MediaStatus status);
        void applicationAboutToQuit();

    private:
        QMediaPlayer *m_player;
        ThumbnailSurface *m_surface;
        QQueue<ThumbnailRequest*> m_requests;
        QMap<qint64, ThumbnailRequest*> m_cache;
        bool m_mediaLoaded;
        bool m_running;
        bool m_exiting;

        ThumbnailRequest* request(qint64 time);
        void clearCache();
        void start();
        void createPlayer();

        QString parseThumbnailName(const QString &id, qint64 *time) const;
};

#endif
