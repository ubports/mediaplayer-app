# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Mediaplayer App"""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools import skipIf
from testtools.matchers import Equals, GreaterThan

from unittest import skip

from mediaplayer_app.tests import MediaplayerAppTestCase


class TestPlayerWithVideo(MediaplayerAppTestCase):
    """Tests the main media player features while playing a video """

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestPlayerWithVideo, self).setUp()
        self.launch_app("small.mp4")
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))
        # wait video player start
        player = self.main_window.get_object("VideoPlayer", "player")
        self.assertThat(player.playing, Eventually(Equals(True)))

    def tearDown(self):
        super(TestPlayerWithVideo, self).tearDown()

    def show_controls(self):
        video_area = self.main_window.get_object("VideoPlayer", "player")
        self.pointing_device.click_object(video_area)
        toolbar = self.main_window.get_object("GenericToolbar", "toolbar")
        self.assertThat(toolbar.ready, Eventually(Equals(True)))

    def pause_video(self):
        playback_buttom = self.main_window.get_object("IconButton", "Controls.PlayBackButton")
        self.pointing_device.click_object(playback_buttom)

    def test_playback_buttom_states(self):
        self.show_controls()

        playback_buttom = self.main_window.get_object("IconButton", "Controls.PlayBackButton")
        player = self.main_window.get_object("VideoPlayer", "player")

        """ Default state after load the video is playing and with pause
        icon.
        """
        self.assertProperty(player, playing=True, paused=False)
        self.assertProperty(playback_buttom, icon="pause")

        self.pointing_device.click_object(playback_buttom)

        """ First click must pause the video, change playing state and show
        play icon. """
        self.assertProperty(player, playing=False, paused=True)
        self.assertProperty(playback_buttom, icon="play")

        self.pointing_device.click()

        """ Second click should change the state to playing again """
        self.assertProperty(player, playing=True, paused=False)
        self.assertProperty(playback_buttom, icon="pause")

    @skipIf(model() == 'Nexus 4' or model() == 'Galaxy Nexus', 'Screen width not enough for seekbar')
    def test_scene_selector_visibility(self):
        self.show_controls()
        self.pause_video()

        scene_selector = self.main_window.get_object("SceneSelector", "Controls.SceneSelector")
        slider = self.main_window.get_object("Slider", "TimeLine.Slider")

        """ Default state is hide """
        self.assertProperty(scene_selector, visible=False)

        """ Scene selector must apper when clicking int the slider handler """
        self.pointing_device.click_object(slider)
        self.assertProperty(scene_selector, visible=True)

        """ click again must dismiss the scene selector """
        self.pointing_device.click()
        self.assertProperty(scene_selector, visible=False)

    @skip("fails on touch and is not reliable on different screen resolutions. bug 1183245")
    def test_scene_selector_operation(self):
        self.show_controls()
        self.pause_video()

        slider = self.main_window.get_object("Slider", "TimeLine.Slider")
        time_line = self.main_window.get_object("TimeLine", "TimeLine")
        selector = self.main_window.get_object("SceneSelector", "Controls.SceneSelector")
        self.assertThat(selector.count, Eventually(GreaterThan(3)))

        """ Show scene selector """
        self.pointing_device.click_object(slider)

        """ Make sure that the scenes are in correct place """
        scene_0 = self.main_window.get_object("SceneFrame", "SceneSelector.Scene0")
        selectorRect = selector.globalRect
        self.pointing_device.drag(
            selectorRect[0], selectorRect[1] + selectorRect[3] / 2,
            selectorRect[0] + selectorRect[2], selectorRect[1] + selectorRect[3] / 2)
        self.assertThat(selector.moving, Eventually(Equals(False)))
        self.assertThat(scene_0.x, Eventually(Equals(0)))

        """ Click in the second scene """
        scene_2 = self.main_window.get_object("SceneFrame", "SceneSelector.Scene2")
        self.assertThat(scene_2.ready, Eventually(Equals(True)))
        self.pointing_device.click_object(scene_2)
        self.assertThat(selector.currentIndex, Eventually(Equals(2)))
        self.assertProperty(time_line, value=1.107)

    @skipIf(model() == 'Nexus 4' or model() == 'Galaxy Nexus', 'Screen width not enough for seekbar')
    def test_time_display_behavior(self):
        self.show_controls()
        self.pause_video()

        time_line = self.main_window.get_object("Slider", "TimeLine.Slider")
        time_label = self.main_window.get_object("Label", "TimeLine.TimeLabel")
        scene_selector = self.main_window.get_object("SceneSelector", "Controls.SceneSelector")

        """ Seek to the midle of the movie """
        self.pointing_device.click_object(time_line)
        self.assertThat(scene_selector.opacity, Eventually(Equals(1)))

        """ Time label must show the current video time (diff from zero or empty) """
        self.assertNotEqual(time_label.text, "00:00:00")
        self.assertNotEqual(time_label.text, "")

        """ Click in the label to change the state """
        self.pointing_device.click_object(time_label)

        """ After the click the label must show the remaning time (with '-' signal) """
        self.assertEqual(time_label.text[0:1], "-")

    @skipIf(model() == 'Nexus 4' or model() == 'Galaxy Nexus', 'Screen width not enough for seekbar')
    def test_show_controls_at_end(self):

        """ wait for video ends and control appears"""
        time_label = self.main_window.get_object("Label", "TimeLine.TimeLabel")

        """ avoid the test fails due the timeout """
        self.assertThat(time_label.text, Eventually(Equals("00:00:05")))
        self.assertThat(time_label.text, Eventually(Equals("00:00:10")))
        self.assertThat(time_label.text, Eventually(Equals("00:00:15")))
        self.assertThat(time_label.text, Eventually(Equals("00:00:20")))
        self.assertThat(time_label.text, Eventually(Equals("00:00:25")))
        
        controls = self.main_window.get_object("Controls", "controls")
        self.assertProperty(controls, visible=False)
        self.assertThat(controls.visible, Eventually(Equals(True)))
