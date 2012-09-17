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

Qt.include("units.js")

function fontSizeToPixels(size) {
    if (mediaPlayer.formFactor == "desktop") {
        switch (size) {
            case "small": return dtPx(13)
            case "medium": return dtPx(15)
            case "large": return dtPx(17)
            case "x-large": return dtPx(20)
            case "xx-large": return dtPx(30)
            case "xxx-large": return dtPx(45)
        }
    } else if (mediaPlayer.formFactor == "tv") {
        switch (size) {
            case "small": return tvPx(30)
            case "medium": return tvPx(35) // NOT USED IN TV (ONLY IN FILTERS)
            case "large": return tvPx(40)
            case "x-large": return tvPx(48)
            case "xx-large": return tvPx(60)
            case "xxx-large": return tvPx(90)
        }
    }
}
