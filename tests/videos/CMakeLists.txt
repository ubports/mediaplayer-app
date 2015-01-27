project(sample_videos)

set(MEDIAPLAYER_TEST_VIDEOS small.ogg small.wmv h264.avi)

install(FILES ${MEDIAPLAYER_TEST_VIDEOS}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/mediaplayer-app/videos
    )
