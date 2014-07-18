# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012, 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Mediaplayer App"""

from __future__ import absolute_import

from autopilot import platform
from autopilot.matchers import Eventually
from testtools.matchers import Equals

from mediaplayer_app.tests import MediaplayerAppTestCase


class TestPlayer(MediaplayerAppTestCase):
    """Tests the main media player features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        if platform.model() == 'Desktop':
            self.skipTest(
                'On desktop, when media player is opened without a video, the '
                'file selection dialog will be opened.')
        super(TestPlayer, self).setUp()
        self.launch_app()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def test_no_video_dialog_visible(self):
        """ Makes sure 'No Video' dialog appears if the meidaplayer is opened
        without a video file argument.

        """
        dialog = self.main_window.get_no_video_dialog()
        self.assertThat(dialog.visible, Eventually(Equals(True)))
