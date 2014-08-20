# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012, 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Mediaplayer App"""

import logging

from autopilot import platform
from autopilot.matchers import Eventually
from testtools.matchers import Equals

from mediaplayer_app.tests import MediaplayerAppTestCase


logger = logging.getLogger(__name__)


class TestPlayerWithVideo(MediaplayerAppTestCase):
    """Tests the main media player features while playing a video """

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestPlayerWithVideo, self).setUp()
        logger.info(platform.model())
        if platform.model() in (
                'Nexus 4', 'Galaxy Nexus', "Nexus 7 (2013) Wi-Fi", "Nexus 10"):
            self.launch_app("h264.avi")
        else:
            self.launch_app("small.ogg")
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))
        # wait video player start
        player = self.main_window.get_player()
        self.assertThat(player.playing, Eventually(Equals(True)))

    def has_seekbar(self):
        return platform.model() == 'Desktop' or platform.is_tablet()

    def show_controls(self):
        video_area = self.main_window.get_video_area()
        self.pointing_device.click_object(video_area)
        toolbar = self.main_window.get_toolbar()
        self.assertThat(toolbar.ready, Eventually(Equals(True)))

    def pause_video(self):
        playback_button = self.main_window.get_playback_button()
        self.pointing_device.click_object(playback_button)

    def test_playback_button_states(self):
        self.show_controls()

        playback_button = self.main_window.get_playback_button()
        player = self.main_window.get_player()

        # Default state after load the video is playing and with pause icon.
        self.assertProperty(player, playing=True, paused=False)
        self.assertProperty(playback_button, icon="pause")

        self.pointing_device.click_object(playback_button)

        # First click must pause the video, change playing state and show play
        # icon.
        self.assertProperty(player, playing=False, paused=True)
        self.assertProperty(playback_button, icon="play")

        self.pointing_device.click()

        # Second click should change the state to playing again
        self.assertProperty(player, playing=True, paused=False)
        self.assertProperty(playback_button, icon="pause")

    def test_time_display_behavior(self):
        if not self.has_seekbar():
            self.skipTest('Screen width not enough for seekbar.')
        self.show_controls()
        self.pause_video()

        time_line = self.main_window.get_slider()
        time_label = self.main_window.get_time_label()

        # Seek to the midle of the movie
        self.pointing_device.click_object(time_line)

        # Time label must show the current video time (diff from zero or empty)
        self.assertNotEqual(time_label.text, "00:00:00")
        self.assertNotEqual(time_label.text, "")

        # Click in the label to change the state
        self.pointing_device.click_object(time_label)

        # After the click the label must show the remaning time (with '-'
        # signal)
        self.assertEqual(time_label.text[0:1], "-")

    def test_show_controls_at_end(self):
        if not self.has_seekbar():
            self.skipTest('Screen width not enough for seekbar.')
        controls = self.main_window.get_controls()
        # The controls are invisible by default
        self.assertThat(controls.visible, Eventually(Equals(False)))

        # wait for video ends and control appears
        self.assertThat(controls.visible, Eventually(Equals(True), timeout=35))
