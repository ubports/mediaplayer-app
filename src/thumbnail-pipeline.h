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
