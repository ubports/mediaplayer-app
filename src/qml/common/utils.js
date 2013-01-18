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
 *
 * The fromIso8601 function is based on:
 * Date.parse with progressive enhancement for ISO 8601 <https://github.com/csnover/js-iso8601>
 * © 2011 Colin Snover <http://zetafleet.com>
 * Released under MIT license.
 *
 * Adapted by Ugo Riboni <ugo.riboni@canonical.com>
 */

.pragma library

/* Default color pallette */
var orange = "#DD4814"
var canonicalAubergine = "#772953"
var lightAubergine = "#77216F"
var mediumAubergine = "#5E2750"
var darkAubergine = "#2C001E"
var darkAubergineDesaturated = "#2c1625"
var warmGrey = "#AEA79F"
var coolGrey = "#333333"
var MS_PER_HOUR = 1000 * 3600

/* Convert strings like "one-two-three" to "OneTwoThree" */
function convertToCamelCase( name ) {
    var chunksArray = name.split('-')
    var camelName = ''
    for (var i=0; i<chunksArray.length; i++){
        camelName = camelName + chunksArray[i].charAt(0).toUpperCase() + chunksArray[i].slice(1);
    }
    return camelName
}

function clamp(x, min, max) {
    return Math.max(Math.min(x, max), min)
}

function isLeftToRight() {
    return Qt.application.layoutDirection == Qt.LeftToRight
}

function isRightToLeft() {
    return Qt.application.layoutDirection == Qt.RightToLeft
}

function switchLeftRightKeys(key) {
    if (isRightToLeft()) {
        switch (key) {
        case Qt.Key_Right:
            return Qt.Key_Left
        case Qt.Key_Left:
            return Qt.Key_Right
        default:
            return key
        }
    }
    return key
}

function hashEmpty(hash) {
    for (var key in hash) return false;
    return true
}

function get_human_time_format(time_in_milliseconds)
{
    var date = new Date(time_in_milliseconds)

    if(date.getUTCHours() == 0) return "mm:ss"
    else return "hh:mm:ss"
}

function removeExt(uri) {
    return uri.substring(0, uri.lastIndexOf("."))
}

function format_time(time_in_milliseconds, formatting) {
    /* We are using Qt.formatTime to format the time_in_milliseconds because
       this is more practical that doing the formatting manually (JavaScript
       does not provide any string formatting function natively).

       WARNING: this will break for media longer than 24 hours.
    */

    /* Hack JavaScript's Date to ignore timeone offset */
    var zero = new Date(0)
    var offset = zero.getTimezoneOffset()*60*1000
    var date = new Date(time_in_milliseconds+offset)

    return Qt.formatTime(date, formatting)
}

function fromIso8601(date) {
    var timestamp, struct, minutesOffset = 0;
    var numericKeys = [ 1, 4, 5, 6, 7, 10, 11 ];

    // ES5 §15.9.4.2 states that the string should attempt to be parsed as a Date Time String Format string
    // before falling back to any implementation-specific date parsing, so that’s what we do, even if native
    // implementations could be faster
    //              1 YYYY                2 MM       3 DD           4 HH    5 mm       6 ss        7 msec        8 Z 9 ±    10 tzHH    11 tzmm
    if ((struct = /^(\d{4}|[+\-]\d{6})(?:-(\d{2})(?:-(\d{2}))?)?(?:T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{3}))?)?(?:(Z)|([+\-])(\d{2})(?::(\d{2}))?)?)?$/.exec(date))) {
        // avoid NaN timestamps caused by “undefined” values being passed to Date.UTC
        for (var i = 0, k; (k = numericKeys[i]); ++i) {
            struct[k] = +struct[k] || 0;
        }

        // allow undefined days and months
        struct[2] = (+struct[2] || 1) - 1;
        struct[3] = +struct[3] || 1;

        if (struct[8] !== 'Z' && struct[9] !== undefined) {
            minutesOffset = struct[10] * 60 + struct[11];

            if (struct[9] === '+') {
                minutesOffset = 0 - minutesOffset;
            }
        }

        timestamp = Date.UTC(struct[1], struct[2], struct[3], struct[4], struct[5] + minutesOffset, struct[6], struct[7]);
        return new Date(timestamp);
    }
    else return null;
}

function isSameDay(date1, date2) {
    return (date1.getFullYear() == date2.getFullYear() &&
            date1.getMonth == date2.getMonth &&
            date1.getDay() == date2.getDay())
}

function pad(text, len, paddingChar) {
    var padding = ""
    for (var i = text.length; i < len; i++) padding += paddingChar
    return padding + text
}

/* DOCME */
function linearInterpolation(xa, xb, a, b, x) {
    return (clamp(x, xa, xb) - xa)/(xb - xa) * (b - a) + a
}

/* DOCME */
function segmentsLinearInterpolation(lx, ly, x) {
    /* FIXME: quick, 5 minutes implementation. Needs cleanup */
    var cxa, cxb, cya, cyb
    for (var i = 0, len = lx.length; i < len; i++) {
        cxa = lx[i]
        cya = ly[i]
        if (cxa <= x) {
            if (i >= len-1) return cya
            cxb = lx[i+1]
            if (x < cxb) {
                cyb = ly[i+1]
                return linearInterpolation(cxa, cxb, cya, cyb, x)
            }
        } else {
            return cya
        }
    }
}
