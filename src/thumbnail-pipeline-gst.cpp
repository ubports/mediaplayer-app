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

#include <QDebug>
#include <gst/gst.h>

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
#if (GST_VERSION_MAJOR  == 1)
	if (gst_element_query_duration (m_pipeline, fmt, &len)) {
#else
	if (gst_element_query_duration (m_pipeline, &fmt, &len)) {
#endif
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

#if (GST_VERSION_MAJOR  == 1)
        m_pipeline = gst_element_factory_make ("playbin", "play");
        m_caps = gst_caps_new_simple ("video/x-raw",
                                      "format", G_TYPE_STRING, "RGB",
                                      "pixel-aspect-ratio", GST_TYPE_FRACTION, 1, 1,
                                      NULL);
#else
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
#endif
        asink = gst_element_factory_make ("fakesink", "audio-fake-sink");
        vsink = gst_element_factory_make ("fakesink", "video-fake-sink");
        g_object_set (vsink, "sync", TRUE, NULL);
        g_object_set (m_pipeline,
                  "audio-sink", asink,
                  "video-sink", vsink,
                  NULL);
    }
}

#if (GST_VERSION_MAJOR  == 1)
static void destroy_frame_data (void *data)
{
    gst_sample_unref (GST_SAMPLE (data));
}

QImage parseImageGst(ThumbnailImageData *buffer)
{
    if (buffer) {
        GstCaps *caps = gst_sample_get_caps (buffer);
        if (caps == 0) {
            qWarning() << "Invalid frame caps";
            return QImage();
        }
        
        
        gint width, height;
        GstStructure *s = gst_caps_get_structure (caps, 0);
        gboolean res = gst_structure_get_int (s, "width", &width);
        res |= gst_structure_get_int (s, "height", &height);
        if (!res) {
            qWarning() << "could not get snapshot dimension";
            return QImage();
        }

        GstMapInfo info;
        GstMemory *memory = gst_buffer_get_memory (gst_sample_get_buffer (buffer), 0);
        gst_memory_map (memory, &info, GST_MAP_READ);
        QImage img = QImage(info.data, width, height, QImage::Format_RGB888, destroy_frame_data, buffer);
        gst_memory_unmap (memory, &info);
        return img;
    } else {
        qWarning() << "Invalid frame data";
    }

    return QImage();
}

#else

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
#endif

QImage ThumbnailPipeline::parseImage(ThumbnailImageData *buffer)
{
    return parseImageGst(buffer);
}

QImage ThumbnailPipeline::request(qint64 time)
{    
    if (m_pipeline == 0) {
        qWarning() << "Pipiline not ready";
        return QImage();
    }

	gst_element_seek (m_pipeline, 1.0,
                      GST_FORMAT_TIME,  static_cast<GstSeekFlags>(GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_KEY_UNIT),
                      GST_SEEK_TYPE_SET, time * GST_MSECOND,
                      GST_SEEK_TYPE_NONE, GST_CLOCK_TIME_NONE);

	/* And wait for this seek to complete */
	gst_element_get_state (m_pipeline, NULL, NULL, GST_CLOCK_TIME_NONE);

    /* get frame */
    ThumbnailImageData *buf = 0;

#if (GST_VERSION_MAJOR  == 1)
    g_signal_emit_by_name (m_pipeline, "convert-sample", m_caps, &buf);
#else
    g_signal_emit_by_name (m_pipeline, "convert-frame", m_caps, &buf);
#endif
    QImage img = parseImage (buf);

    return img;
}
