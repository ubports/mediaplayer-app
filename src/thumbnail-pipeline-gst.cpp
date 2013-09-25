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

#include <QDebug>
#include <gst/gst.h>
#include <math.h>

#include "thumbnail-pipeline-gst.h"

ThumbnailPipeline::ThumbnailPipeline()
    : m_pipeline(0),
      m_caps(0),
      m_duration(0),
      m_uri(0)
{
    gst_init(0, 0);
}

ThumbnailPipeline::~ThumbnailPipeline()
{
    stop();
}

QString ThumbnailPipeline::uri() const
{
    return QString::fromUtf8(m_uri);
}

void ThumbnailPipeline::setUri(const QString &new_uri)
{
    const gchar *g_uri = new_uri.toUtf8().data();
    if (g_strcmp0(m_uri, g_uri) != 0) {
        stop();
        m_uri = g_strdup(g_uri);
        start();
    }
}

void ThumbnailPipeline::stop()
{
    if (m_caps) {
        gst_caps_unref (m_caps);
        m_caps = 0;
    }

    if (m_pipeline) {
        gst_element_set_state (m_pipeline, GST_STATE_NULL);
        gst_object_unref (m_pipeline);
        m_pipeline = 0;
    }

    if (m_uri) {
        g_free (m_uri);
        m_uri = 0;
    }
}

bool ThumbnailPipeline::start()
{
    setup();
    g_object_set (m_pipeline, "uri", m_uri, NULL);
    GstStateChangeReturn ret = gst_element_set_state (m_pipeline, GST_STATE_PAUSED);
    switch (ret)
    {
        case GST_STATE_CHANGE_FAILURE:
            qWarning() << "Fail to start thumbnail pipeline";
            return false;
        case GST_STATE_CHANGE_NO_PREROLL:
            qWarning() << "Thumbnail not supported for live sources";
            return false;
        default:
            break;
    }

    ret = gst_element_get_state (m_pipeline, NULL, NULL, 5 * GST_SECOND);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        qWarning() << "failed to play the file:" << m_uri;
        return false;
    }


	GstFormat fmt = GST_FORMAT_TIME;
	gint64 len = -1;
	if (gst_element_query_duration (m_pipeline, &fmt, &len)) {
        if (len > 0) {
    		m_duration = len / GST_MSECOND;
            return true;
        }
    }

    return false;
}

void ThumbnailPipeline::setup()
{
    if (m_pipeline == 0) {
        GstElement *asink;
        GstElement *vsink;

        m_pipeline = gst_element_factory_make ("playbin2", "play");
        m_caps = gst_caps_new_simple ("video/x-raw-rgb",
                                      "bpp", G_TYPE_INT, 24,
                                      "depth", G_TYPE_INT, 24,
                                      "pixel-aspect-ratio", GST_TYPE_FRACTION, 1, 1,
                                      "endianness", G_TYPE_INT, G_BIG_ENDIAN,
                                      "red_mask", G_TYPE_INT, 0xff0000,
                                      "green_mask", G_TYPE_INT, 0x00ff00,
                                      "blue_mask", G_TYPE_INT, 0x0000ff,
                                      NULL);
        asink = gst_element_factory_make ("fakesink", "audio-fake-sink");
        vsink = gst_element_factory_make ("fakesink", "video-fake-sink");
        g_object_set (vsink, "sync", TRUE, NULL);
        g_object_set (m_pipeline,
                  "flags", 0x00000001, // Make sure to render only the video stream (we do not need audio here)
                  "audio-sink", asink,
                  "video-sink", vsink,
                  NULL);
    }
}

static void destroy_frame_data (void *data)
{
    gst_buffer_unref (GST_BUFFER (data));
}

QImage parseImageGst(ThumbnailImageData *buffer)
{
    if (buffer && GST_BUFFER_CAPS (buffer)) {
        gint width, height;
        GstStructure *s = gst_caps_get_structure (GST_BUFFER_CAPS (buffer), 0);
        gboolean res = gst_structure_get_int (s, "width", &width);
        res |= gst_structure_get_int (s, "height", &height);
        if (!res) {
            qWarning() << "could not get snapshot dimension";
            return QImage();
        }

        return QImage(GST_BUFFER_DATA (buffer), width, height, QImage::Format_RGB888, destroy_frame_data, buffer);
    }

    return QImage();
}

QImage ThumbnailPipeline::parseImage(ThumbnailImageData *buffer) const
{
    return parseImageGst(buffer);
}

// use standard deviation of the histogram to discovery a good image
bool ThumbnailPipeline::isMeaningful(QImage img)
{
    const static int threshold = 15;
    const float average = (img.height() * img.width()) / 256;
    int histogram[256];

    memset(histogram, 0, sizeof(int) * 256);
    for(int h=0, hMax = img.height(); h < hMax; h++) {
        for(int w=0, wMax = img.width(); w < wMax; w++) {
            histogram[qGray(img.pixel(w, h))]++;
        }
    }

    float sum = 0;
    for(int i=0; i < 256; i++) {
        sum += pow(average - histogram[i], 2);
    }

    return ((sqrt(sum / 256) / average) <= threshold);
}

QImage ThumbnailPipeline::request(qint64 time, QSize size, bool skipBlack)
{
    if (m_pipeline == 0) {
        qWarning() << "Pipiline not ready";
        return QImage();
    }


    QImage firstImage;
    while(time < m_duration) {
        gst_element_seek (m_pipeline, 1.0,
                          GST_FORMAT_TIME,  static_cast<GstSeekFlags>(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_KEY_UNIT),
                          GST_SEEK_TYPE_SET, time * GST_MSECOND,
                          GST_SEEK_TYPE_NONE, GST_CLOCK_TIME_NONE);

        /* And wait for this seek to complete */
        gst_element_get_state (m_pipeline, NULL, NULL, GST_CLOCK_TIME_NONE);

        /* get frame */
        ThumbnailImageData *buf = 0;

        g_signal_emit_by_name (m_pipeline, "convert-frame", m_caps, &buf);
        QImage img = parseImage (buf);
        if (size.isValid()) {
            img = img.scaled(size, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        }

        if (skipBlack && !isMeaningful (img)) {
            if (firstImage.isNull()) {
                firstImage = img.copy();
            }
            time += 1000;
            continue;
        } else {
            return img;
        }
    }

    // return the original frame if any other was found
    return firstImage;
}
