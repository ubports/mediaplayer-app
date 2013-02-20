/*
 * Copyright (C) 2012-2013 Canonical, Ltd.
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

#include "sharefile.h"

#include <QtCore/QFileInfo>
#include <QtCore/QFile>
#include <QtCore/QDir>
#include <QtCore/QTextStream>
#include <QtCore/QDebug>
#include <QtCore/QTemporaryFile>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickImageProvider>

ShareFile::ShareFile(QObject *parent) :
    QObject(parent)
{
}

QString ShareFile::saveImageFromProvider(const QString &imageUri)
{
    // Get image provider
    QQmlContext *ctx =  QQmlEngine::contextForObject(this);
    if (ctx == 0) {
        qWarning() << "Share object does not have a QML context.";
        return QString();
    }

    QQmlEngine *eng = ctx->engine();
    if (eng == 0) {
        qWarning() << "Share object does not have a QML engine.";
        return QString();
    }

    // parse uri (image://<provider>/<file-id>)
    QString tempUri(imageUri.mid(8));
    QStringList uriParts = tempUri.split("/");
    if (uriParts.count() < 2) {
        qWarning() << "Invalid image uri.";
        return QString();
    }

    QString providerName = uriParts.takeFirst();
    QQmlImageProviderBase *provider = eng->imageProvider(providerName);
    if (provider == 0) {
        qWarning() << "Image provider not found: " << provider;
        return QString();
    }

    QQuickImageProvider *qprovider = (QQuickImageProvider*) provider;
    QSize size;
    QImage img = qprovider->requestImage(uriParts.join("/"), &size, QSize());

    QTemporaryFile tempFile;
    tempFile.setAutoRemove(false);
    if (img.save(&tempFile, "png")) {
        return tempFile.fileName();
    } else {
        qWarning() << "Fail to save image from provider.";
        return QString();
    }
}

void ShareFile::writeShareFile(const QString &path)
{
    QString newPath = path;
    if (path.startsWith("image://")) {
        newPath = saveImageFromProvider(path);
    }

    QFileInfo imageFilePath(QDir::tempPath() + QDir::separator() + "sharelocation");
    QFile imageFile(imageFilePath.absoluteFilePath());
    if (imageFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream stream(&imageFile);
        stream << newPath;
        imageFile.close();
    } else {
        qWarning() << "Failed to open share file for writing";
    }
}
