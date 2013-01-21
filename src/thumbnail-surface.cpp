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

#include "thumbnail-surface.h"

ThumbnailSurface::ThumbnailSurface(QObject *parent)
    : QAbstractVideoSurface(parent),
      m_videoFormat(QImage::Format_Invalid)
{
}

QList<QVideoFrame::PixelFormat> ThumbnailSurface::supportedPixelFormats(QAbstractVideoBuffer::HandleType handleType) const
{
    if (handleType == QAbstractVideoBuffer::NoHandle)
    {
        return QList<QVideoFrame::PixelFormat>()
                << QVideoFrame::Format_RGB32
                << QVideoFrame::Format_ARGB32
                << QVideoFrame::Format_ARGB32_Premultiplied
                << QVideoFrame::Format_RGB565
                << QVideoFrame::Format_RGB555;
    }
    else
    {
        return QList<QVideoFrame::PixelFormat>();
    }
}

bool ThumbnailSurface::isFormatSupported(const QVideoSurfaceFormat & format) const
{
    const QImage::Format imageFormat = QVideoFrame::imageFormatFromPixelFormat(format.pixelFormat());
    const QSize size = format.frameSize();

    return imageFormat != QImage::Format_Invalid
            && !size.isEmpty()
            && format.handleType() == QAbstractVideoBuffer::NoHandle;
}

bool ThumbnailSurface::start(const QVideoSurfaceFormat &format)
{
    const QImage::Format imageFormat = QVideoFrame::imageFormatFromPixelFormat(format.pixelFormat());
    const QSize size = format.frameSize();

    if ((imageFormat != QImage::Format_Invalid) && !size.isEmpty()) {
        m_videoFormat = imageFormat;

        return QAbstractVideoSurface::start(format);
    } else {
        if (size.isEmpty()) {
            qWarning() << "Invalid video size:" << size;
        } else {
            qWarning() << "Invalid frame format:" << format.pixelFormat();
        }
        return false;
    }
}

bool ThumbnailSurface::present(const QVideoFrame &frame)
{
    QVideoFrame cpyFrame(frame);
    if (cpyFrame.map(QAbstractVideoBuffer::ReadOnly)) {
        QImage image(cpyFrame.bits(),
                     cpyFrame.width(),
                     cpyFrame.height(),
                     cpyFrame.bytesPerLine(),
                     m_videoFormat);

        Q_EMIT newFrame(cpyFrame.endTime(), image);
        cpyFrame.unmap();
    }

    return true;
}
