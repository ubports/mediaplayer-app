/*
 * Copyright (C) 2012 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
 *  Michał Sawicz <michal.sawicz@canonical.com>
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

// Qt
#include <QGuiApplication>

// local
#include "mediaplayer.h"
#include "config.h"

int main(int argc, char** argv)
{
    unsetenv("QML_FORCE_THREADED_RENDERER");
    unsetenv("QML_FIXED_ANIMATION_STEP");
    setenv("QML_BAD_GUI_RENDER_LOOP", "1", 1);

    QGuiApplication::setApplicationName("Media Player");
    MediaPlayer application(argc, argv);

    if (!application.setup()) {
        return 1;
    }

    return application.exec();
}

