include(${CMAKE_SOURCE_DIR}/cmake/autopilot.cmake)
declare_autopilot_test(MEDIAPLAYER_APP=${mediaplayer_src_BINARY_DIR}/media-player
                       mediaplayer_app
                       ${CMAKE_CURRENT_SOURCE_DIR})
