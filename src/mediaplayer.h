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

#ifndef MEDIAPLAYER_H
#define MEDIAPLAYER_H

#include <QtQuick/QQuickView>
#include <QtWidgets/QApplication>
#include <QtWidgets/QFileDialog>
#include <QUrl>

class MediaPlayer : public QApplication
{
    Q_OBJECT
    Q_PROPERTY(bool desktopMode READ isDesktopMode CONSTANT)

public:
    MediaPlayer(int &argc, char **argv);
    virtual ~MediaPlayer();

    bool setup();

public Q_SLOTS:
    void toggleFullscreen();
    void leaveFullScreen();
    void onWidthChanged(int);
    void onHeightChanged(int);
    bool isDesktopMode() const;
    QUrl chooseFile();
    QList<QUrl> copyFiles(const QList<QUrl> &urls);

private:
    QQuickView *m_view;
    QFileDialog *m_fileChooser;
};

#endif // MEDIAPLAYER_H
