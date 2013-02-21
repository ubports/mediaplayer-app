# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Mediaplayer App"""

from __future__ import absolute_import

from testtools.matchers import Equals, NotEquals, GreaterThan
from autopilot.matchers import Eventually

from mediaplayer_app.tests import MediaplayerAppTestCase

import unittest
import time
import os
from os import path

class TestPlayerWithVideo(MediaplayerAppTestCase):
    """Tests the main media player features while playing a video """

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestPlayerWithVideo, self).setUp()
        self.launch_app("../videos/small.mp4")
        self.assertThat(self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestPlayerWithVideo, self).tearDown()

    def show_controls(self):
        video_area = self.main_window.get_object("player")
        self.mouse.move_to_object(video_area)
        self.mouse.click()

    def pause_video(self):
        playback_buttom = self.main_window.get_object("Controls.PlayBackButton")
        self.mouse.move_to_object(playback_buttom)
        self.mouse.click()

    """ Test scene selector visibility """
    def test_scene_selector_visibility(self):
        self.show_controls()
        self.pause_video()

        scene_selector = self.main_window.get_object("Controls.SceneSelector")
        slider = self.main_window.get_object("TimeLine.Slider")

        """ Default state is hide """
        self.assertProperty(scene_selector, visible=False)

        """ Scene selector must apper when clicking int the slider handler """
        self.mouse.move_to_object(slider)
        self.mouse.click()
        self.assertProperty(scene_selector, visible=True)

        """ click again must dismiss the scene selector """
        self.mouse.click()
        self.assertProperty(scene_selector, visible=False)

    def test_scene_selector_operation(self):
        self.show_controls()
        self.pause_video()

        scene_selector = self.main_window.get_object("Controls.SceneSelector")
        slider = self.main_window.get_object("TimeLine.Slider")
        time_line = self.main_window.get_object("TimeLine")

        self.mouse.move_to_object(slider)
        self.mouse.click()

        self.mouse.move_to_object(scene_selector)
        self.mouse.click()

        self.assertProperty(time_line, value=1.67)

