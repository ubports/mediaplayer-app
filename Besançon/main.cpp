#include <QApplication>
#include <QGLFormat>
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    QmlApplicationViewer viewer;

    QGLFormat format = QGLFormat::defaultFormat();
    format.setSampleBuffers(false);
    QGLWidget *glWidget = new QGLWidget(format);
    glWidget->setAutoFillBackground(false);

    viewer.setViewport(glWidget);

    viewer.setMainQmlFile(QLatin1String("qml/qml/player.qml"));
    viewer.show();
//    viewer.showFullScreen();

    return app->exec();
}
