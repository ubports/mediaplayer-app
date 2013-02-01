#include <QDebug>
#include <gst/gst.h>

#include "thumbnail-pipeline.h"

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
    bool m_exiting;
};

class FrameInfo
{
public:
    GstMapInfo map;
    GstBuffer *buffer;
    FrameInfo()
        : buffer(0)
    {
    }

    ~FrameInfo()
    {
        gst_buffer_unmap (buffer, &map);
    }

    static void destroy(void *info)
    {
        delete static_cast<FrameInfo*>(info);
    }
};

ThumbnailRequest::ThumbnailRequest(qint64 time)
    : m_time(time),
      m_exiting(false)
{
    gst_init (0, 0);
}

ThumbnailRequest::~ThumbnailRequest()
{
    m_exiting = true;
}

qint64 ThumbnailRequest::time() const
{
    return m_time;
}


ThumbnailPipeline::ThumbnailPipeline(QObject *parent)
    : QObject(parent),
      m_pipeline(0),
      m_sink(0),
      m_running(false)
{
    qDebug() << "INIT GST";
    gst_init (0, 0);
}

ThumbnailPipeline::~ThumbnailPipeline()
{
    stop();
}

QString ThumbnailPipeline::uri() const
{
    return m_uri;
}

void ThumbnailPipeline::setUri(const QString &uri)
{
    if (m_uri != uri) {
        stop();
        m_uri = uri;
        setup();
    }
}

void ThumbnailPipeline::stop()
{
    if (m_pipeline) {
        gst_element_set_state (m_pipeline, GST_STATE_NULL);
        gst_object_unref (m_pipeline);
    }
}

bool ThumbnailPipeline::start()
{
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
    return true;
}

void ThumbnailPipeline::setup()
{
    static QString CAPS = QString("video/x-raw,format=RGB16,pixel-aspect-ratio=1/1");

    QString pipeLine = QString("uridecodebin uri=%1 ! videoconvert ! appsink name=sink caps=\"%2\"")
            .arg(m_uri)
            .arg(CAPS);

    GError *error = NULL;
    m_pipeline = gst_parse_launch (pipeLine.toUtf8(), &error);
    if (error != NULL) {
        m_pipeline = NULL;
        qWarning() << "Fail to create thumbnail pipeline: " << error->message;
        g_error_free (error);
    }

    m_sink = gst_bin_get_by_name (GST_BIN (m_pipeline), "sink");
    start();
}

 QImage ThumbnailPipeline::parseImage(GstSample *sample)
{
    if (sample) {
        GstCaps *caps;

        caps = gst_sample_get_caps (sample);
        if (!caps) {
          qWarning() << "could not get snapshot format";
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

        FrameInfo *info = new FrameInfo;

        info->buffer = gst_sample_get_buffer (sample);
        gst_buffer_map (info->buffer, &(info->map), GST_MAP_READ);
        return QImage(info->map.data, width, height, QImage::Format_RGB16, FrameInfo::destroy, info);
    }
}

QImage ThumbnailPipeline::request(qint64 time)
{
    if (m_pipeline == 0) {
        qWarning() << "Pipiline not ready";
        return QImage();
    }

    gst_element_seek_simple (m_pipeline,
                             GST_FORMAT_TIME,
                             (GstSeekFlags) (GST_SEEK_FLAG_KEY_UNIT | GST_SEEK_FLAG_FLUSH),
                             (time / 1000) * GST_SECOND); //request->time());

    GstSample *sample;
    g_signal_emit_by_name (m_sink, "pull-preroll", &sample, NULL);
    QImage img = parseImage (sample);
    gst_sample_unref (sample);
    return img;
}
