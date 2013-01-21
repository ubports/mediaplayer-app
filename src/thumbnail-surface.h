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

#ifndef THUMBNAIL_SURFACE_H
#define THUMBNAIL_SURFACE_H

#include "thumbnail-provider.h"

#include <QtMultimedia/QAbstractVideoSurface>

class ThumbnailSurface : public QAbstractVideoSurface
{
    Q_OBJECT

public:
     ThumbnailSurface(QObject *parent = 0);
     QList<QVideoFrame::PixelFormat> supportedPixelFormats(QAbstractVideoBuffer::HandleType type = QAbstractVideoBuffer::NoHandle) const;
     bool isFormatSupported(const QVideoSurfaceFormat & format) const;
     bool start(const QVideoSurfaceFormat &format);
     bool present(const QVideoFrame &frame);

     QImage getFrame();

signals:
     void newFrame(qint64 time, QImage &frame);

private:
    QImage::Format m_videoFormat;
};

#endif
