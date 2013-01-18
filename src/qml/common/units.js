/*
 * This file is part of unity-2d
 *
 * Copyright 2011 Canonical Ltd.
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

var desktopDistanceToDisplay = 0.5
var desktopPixelDensity = 112

var tvDistanceToDisplay = 2.0
var tvPixelDensity = 52 // 1080p on a 42" screen

/* distanceToDisplay and pixelDensity cannot be global javascript variables
   because they would not be able to access unity2dConfiguration.formFactor
*/
function dtPx(desktopPixels) {
    var distanceToDisplay = mediaPlayer.formFactor === "desktop" ? desktopDistanceToDisplay : tvDistanceToDisplay
    var pixelDensity = mediaPlayer.formFactor === "desktop" ? desktopPixelDensity : tvPixelDensity
    var factorFromDesktop = pixelDensity / desktopPixelDensity * distanceToDisplay / desktopDistanceToDisplay
    return desktopPixels * factorFromDesktop
}

function tvPx(tvPixels) {
    var distanceToDisplay = mediaPlayer.formFactor === "desktop" ? desktopDistanceToDisplay : tvDistanceToDisplay
    var pixelDensity = mediaPlayer.formFactor === "desktop" ? desktopPixelDensity : tvPixelDensity
    var factorFromTv = pixelDensity / tvPixelDensity * distanceToDisplay / tvDistanceToDisplay
    return tvPixels * factorFromTv
}
