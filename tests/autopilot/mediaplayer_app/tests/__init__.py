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

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase

from mediaplayer_app.emulators.main_window import MainWindow


class MediaplayerAppTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    mediaplayer-app tests.

    """

    if model() == 'Desktop':
        scenarios = [
            ('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [
            ('with touch', dict(input_device_class=Touch))]

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(MediaplayerAppTestCase, self).setUp()

    def launch_app(self, movie_file=None):
        if movie_file is None:
            movie_file = ""
        # Lets assume we are installed system wide if this file is somewhere
        # in /usr
        if os.path.realpath(__file__).startswith("/usr/"):
            self.launch_test_installed(movie_file)
        else:
            self.launch_test_local(movie_file)

    def launch_test_local(self, movie_file):
        mp_app = os.environ['MEDIAPLAYER_APP']
        mp_data_dir = os.environ['MEDIAPLAYER_DATA_DIR']
        if mp_app:
            self.app = self.launch_test_application(
                mp_app,
                "-w",
                "file://%s/%s" % (mp_data_dir, movie_file))
        else:
            self.app = None

    def launch_test_installed(self, movie_file):
        if model() == 'Desktop':
            self.app = self.launch_test_application(
                "mediaplayer-app",
                "-w",
                "/usr/share/mediaplayer-app/videos/" + movie_file)
        else:
            self.app = self.launch_test_application(
                "mediaplayer-app",
                "file:///usr/share/mediaplayer-app/videos/" + movie_file,
                "--fullscreen",
                "--desktop_file_hint=/usr/share/applications/mediaplayer-app.desktop",
                app_type='qt')

    @property
    def main_window(self):
        return MainWindow(self.app)
