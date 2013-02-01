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

#ifndef THUMBNAIL_PIPELINE_H
#define THUMBNAIL_PIPELINE_H

#include <QObject>
#include <QImage>
#include <QQueue>
#include <QMap>

#include <gst/gst.h>

class ThumbnailRequest;
class ThumbnailPipeline : public QObject
{
    Q_OBJECT

public:
    ThumbnailPipeline(QObject *parent);
    ~ThumbnailPipeline();

    void setUri(const QString &uri);
    QString uri() const;

    QImage request(qint64 time);

Q_SIGNALS:
    void newImage(qint64 time, const QImage &img);

private:
    QQueue<ThumbnailRequest*> m_requests;
    QMap<qint64, ThumbnailRequest*> m_cache;

    GstElement *m_pipeline;
    GstElement *m_sink;
    bool m_running;
    QString m_uri;

    void setup();
    bool start();
    void stop();
    QImage parseImage(GstSample *sample);
    void prepareNextFrame();
};

#endif
