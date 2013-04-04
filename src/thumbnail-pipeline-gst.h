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

#ifndef THUMBNAIL_PIPELINE_GST_010_H
#define THUMBNAIL_PIPELINE_GST_010_H

#include <QImage>
#include <gst/gst.h>

typedef GstBuffer ThumbnailImageData;
class ThumbnailPipeline 
{
public:
    ThumbnailPipeline();
    ~ThumbnailPipeline();

    void setUri(const QString &uri);
    QString uri() const;

    QImage request(qint64 time, QSize size, bool skipBlack=true);

private:
    GstElement *m_pipeline;
    GstCaps *m_caps;
    gchar *m_uri;
    qint64 m_duration;

    void setup();
    bool start();
    void stop();
    QImage parseImage(ThumbnailImageData *buffer);
    bool isMeaningful(QImage img);
};

#endif
