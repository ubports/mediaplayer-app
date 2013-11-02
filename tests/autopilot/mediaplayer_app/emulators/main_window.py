# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


class MainWindow(object):
    """An emulator class that makes it easy to interact with the camera-app."""

    def __init__(self, app):
        self.app = app

    def get_qml_view(self):
        """Get the main QML view"""
        return self.app.select_single("QQuickView")

    def get_controls(self):
    	return self.app.select_single("Controls", objectName="controls")

    def get_video_area(self):
    	return self.app.select_single("VideoPlayer", objectName="player")

    def get_toolbar(self):
        return self.app.select_single("GenericToolbar", objectName="toolbar")

    def get_playback_button(self):
        return self.app.select_single("IconButton", objectName="Controls.PlayBackButton")

    def get_player(self):
        return self.app.select_single("VideoPlayer", objectName="player")

    def get_scene_selector(self):
        return self.app.select_single("SceneSelector", objectName="Controls.SceneSelector")

    def get_slider(self):
        return self.app.select_single("Slider", objectName="TimeLine.Slider")

    def get_timeline(self):
        return self.app.select_single("TimeLine", objectName="TimeLine")

    def get_scene_0(self):
        return self.app.select_single("SceneFrame", objectName="SceneSelector.Scene0")

    def get_scene_2(self):
        return self.app.select_single("SceneFrame", objectName="SceneSelector.Scene2")

    def get_time_label(self):
        return self.app.select_single("Label", objectName="TimeLine.TimeLabel")

    def get_no_video_dialog(self):
        return self.app.select_single("Dialog", objectName="noMediaDialog")
