# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""mediaplayer-app autopilot tests."""

from os import remove
import os.path
import os

from autopilot.testcase import AutopilotTestCase

from mediaplayer_app.emulators.main_window import MainWindow

class MediaplayerAppTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for mediaplayer-app tests."""

    def setUp(self):
        super(MediaplayerAppTestCase, self).setUp()

    def launch_app(self, movie_file=None):
        if movie_file == None:
            movie_file = ""
        # Lets assume we are installed system wide if this file is somewhere in /usr
        if os.path.realpath(__file__).startswith("/usr/"):
            self.launch_test_installed(movie_file)
        else:
            self.launch_test_local(movie_file)

    def launch_test_local(self, movie_file):
        mp_app = os.environ['MEDIAPLAYER_APP']
        if mp_app:
            self.app = self.launch_test_application(
                    mp_app,
                    "-w",
                    "../videos/" + movie_file)
        else:
            self.app = None

    def launch_test_installed(self, movie_file):
        if self.running_on_device():
            self.app = self.launch_test_application(
               "media-player",
               "--fullscreen ",
               movie_file)
        else:
            self.app = self.launch_test_application(
               "media-player",
               "-w",
               "/usr/share/media-player/videos/" + movie_file)

    @staticmethod
    def running_on_device():
        return os.path.isfile('/system/usr/idc/autopilot-finger.idc')

    @property
    def main_window(self):
        return MainWindow(self.app)

