/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Renato Araujo Oliveira Filho <renato@canonical.com>
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

class ThumbnailPipeline;

class ThumbnailProvider : public QObject, public QQuickImageProvider
{
    Q_OBJECT

    public:
        ThumbnailProvider();
        ~ThumbnailProvider();

        QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

    private Q_SLOTS:
        void applicationAboutToQuit();

    private:
        ThumbnailPipeline *m_player;
        QMap<qint64, QImage> m_cache;

        void createPlayer();
        QString parseThumbnailName(const QString &id, qint64 *time) const;
};

#endif
