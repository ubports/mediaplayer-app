/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include "thumbnail-pipeline-gst.h"
#include "test-config.h"

#include <QtTest>
#include <QDebug>
#include <QImage>

class ThumbnailTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    void testImageIsMeaningful_data()
    {
        QTest::addColumn<QString>("path");
        QTest::addColumn<bool>("expectedResult");

        QTest::newRow("black image") << QString(SAMPLE_IMAGES_DIR) + "/frame0.png" << false;
        QTest::newRow("non black image") << QString(SAMPLE_IMAGES_DIR) + "/frame10.png" << true;
        QTest::newRow("collored image") << QString(SAMPLE_IMAGES_DIR) + "/frame20.png" << true;
        QTest::newRow("almost black image") << QString(SAMPLE_IMAGES_DIR) + "/frame100.png" << false;
    }

    void testImageIsMeaningful()
    {
        QFETCH(QString, path);
        QFETCH(bool, expectedResult);

        QImage img = QImage(path);
        QVERIFY(!img.isNull());

        bool result = ThumbnailPipeline::isMeaningful(img);
        QCOMPARE(result, expectedResult);
    }
};

QTEST_MAIN(ThumbnailTest)

#include "thumbnailtest.moc"
