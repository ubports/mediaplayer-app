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
        self.launch_app("small.mp4")
        self.assertThat(self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestPlayerWithVideo, self).tearDown()

    def show_controls(self):
        video_area = self.main_window.get_object("VideoPlayer", "player")
        self.mouse.move_to_object(video_area)
        self.mouse.click()
        toolbar = self.main_window.get_object("GenericToolbar", "toolbar")
        self.assertThat(toolbar.ready, Eventually(Equals(True)))

    def pause_video(self):
        playback_buttom = self.main_window.get_object("IconButton", "Controls.PlayBackButton")
        self.mouse.move_to_object(playback_buttom)
        self.mouse.click()

    def test_playback_buttom_states(self):
        self.show_controls()

        playback_buttom = self.main_window.get_object("IconButton", "Controls.PlayBackButton")
        player = self.main_window.get_object("VideoPlayer", "player")

        """ Default state after load the video is playing and with pause icon """
        self.assertProperty(player, playing=True, paused=False)
        self.assertProperty(playback_buttom, icon="pause")

        self.mouse.move_to_object(playback_buttom)
        self.mouse.click()

        """ First click must pause the video, change playing state and show play icon """
        self.assertProperty(player, playing=False, paused=True)
        self.assertProperty(playback_buttom, icon="play")

        self.mouse.click()

        """ Second click should change the state to playing again """
        self.assertProperty(player, playing=True, paused=False)
        self.assertProperty(playback_buttom, icon="pause")


    def test_scene_selector_visibility(self):
        self.show_controls()
        self.pause_video()

        scene_selector = self.main_window.get_object("SceneSelector", "Controls.SceneSelector")
        slider = self.main_window.get_object("Slider", "TimeLine.Slider")

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

        slider = self.main_window.get_object("Slider", "TimeLine.Slider")
        time_line = self.main_window.get_object("TimeLine", "TimeLine")
        selector = self.main_window.get_object("SceneSelector", "Controls.SceneSelector")
        self.assertThat(selector.count, Eventually(GreaterThan(3)))

        scene_2 = self.main_window.get_object("SceneFrame", "SceneSelector.Scene2")
        self.assertThat(scene_2.ready, Eventually(Equals(True)))


        """ Show scene selector """
        self.mouse.move_to_object(slider)
        self.mouse.click()

        """ Make sure that the scenes are in correct place """
        selectorRect = selector.globalRect
        self.pointing_device.drag(selectorRect[0], selectorRect[1] + selectorRect[3] / 2,
                                  selectorRect[0] + selectorRect[2], selectorRect[1] + selectorRect[3] / 2)
        scene_0 = self.main_window.get_object("SceneFrame", "SceneSelector.Scene0")
        self.assertThat(scene_0.x, Eventually(GreaterThan(-1)))


        """ Click in the second scene """
        self.mouse.move_to_object(scene_2)
        self.mouse.click()
        self.assertThat(selector.currentIndex, Eventually(Equals(2)))

        self.assertProperty(time_line, value=1.113)

    def test_time_display_behavior(self):
        self.show_controls()
        self.pause_video()

        time_line = self.main_window.get_object("Slider", "TimeLine.Slider")
        time_label = self.main_window.get_object("Label", "TimeLine.TimeLabel")

        """ Seek to the midle of the movie """
        self.mouse.move_to_object(time_line)
        self.mouse.click()

        """ Time label must show the current video time
            - Depends on the resolution the current time can be different due the slider size,
              because of that we avoid compare the secs
        """
        self.assertEqual(time_label.text[0:7], "00:00:0")

        """ Click in the label to change the state """
        self.mouse.move_to_object(time_label)
        self.mouse.click()

        """ After the click the label must show the remaning time
            - Depends on the resolution the current time can be different due the slider size,
              because of that we avoid compare the secs
        """
        self.assertEqual(time_label.text[0:9], "- 00:00:0")





