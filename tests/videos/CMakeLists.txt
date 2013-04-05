project(sample_videos)

set(MEDIAPLAYER_TEST_VIDEOS small.mp4)

install(FILES ${MEDIAPLAYER_TEST_VIDEOS}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/media-player/videos
    )
