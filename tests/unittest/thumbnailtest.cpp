/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

#include "thumbnail-pipeline-gst.h"
#include "test-config.h"

#include <QtTest>
#include <QDebug>
#include <QImage>

class ThumbnailTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    /*
     * Test if a black image is a valid frame
     */
    void testImageBlackIsMeaningful()
    {
        QImage blackFrame = QImage(QString(SAMPLE_IMAGES_DIR) + "/frame0.png");
        QVERIFY(!blackFrame.isNull());

        // black frame is not acceptable
        QCOMPARE(ThumbnailPipeline::isMeaningful(blackFrame), false);
    }

    /*
     * Test if a non black image is a valid frame
     */
    void testImageFireworksIsMeaningful()
    {
        QImage fireworksFrame = QImage(QString(SAMPLE_IMAGES_DIR) + "/frame10.png");
        QVERIFY(!fireworksFrame.isNull());

        // non black frame is acceptable
        QCOMPARE(ThumbnailPipeline::isMeaningful(fireworksFrame), true);
    }


    /*
     * Test if a collored image is a valid frame
     */
    void testImageUbuntuIsMeaningful()
    {
        QImage ubuntuFrame = QImage(QString(SAMPLE_IMAGES_DIR) + "/frame20.png");
        QVERIFY(!ubuntuFrame.isNull());

        // collored frame is acceptable
        QCOMPARE(ThumbnailPipeline::isMeaningful(ubuntuFrame), true);
    }


    /*
     * Test if a almost black image is a valid frame
     */
    void testTheEndIsMeaningful()
    {
        QImage theEndFrame = QImage(QString(SAMPLE_IMAGES_DIR) + "/frame100.png");
        QVERIFY(!theEndFrame.isNull());

        // almost black frame is not acceptable
        QCOMPARE(ThumbnailPipeline::isMeaningful(theEndFrame), false);
    }



};

QTEST_MAIN(ThumbnailTest)

#include "thumbnailtest.moc"
