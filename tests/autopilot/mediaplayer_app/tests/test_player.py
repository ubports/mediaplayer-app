# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Mediaplayer App"""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals

from mediaplayer_app.tests import MediaplayerAppTestCase


class TestPlayer(MediaplayerAppTestCase):
    """Tests the main media player features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestPlayer, self).setUp()
        self.launch_app()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestPlayer, self).tearDown()

    """ Test if the toolbar appears with mouse click over the video area """
    def test_controls_visibility(self):
        controls = self.main_window.get_controls()

        """ The toolbar is invisible by default """
        self.assertFalse(controls.visible)

        """ Toolbar must appear when clicked in the video area """
        video_area = self.main_window.get_video_area()
        self.pointing_device.click_object(video_area)
        self.assertThat(controls.visible, Eventually(Equals(True)))

        """ Toolbar must disappear when clicked in the video area again """
        self.pointing_device.click()
        self.assertThat(controls.visible, Eventually(Equals(False)))
