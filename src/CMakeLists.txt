project(mediaplayer_src)

set(MEDIAPLAYER mediaplayer-app)

include_directories(
    ${CMAKE_BINARY_DIR}
    ${sdkhelper_SOURCE_DIR}
    #${GSTLIB_INCLUDE_DIRS}
    )

set(mediaplayer_HDRS
    #thumbnail-provider.h
    #thumbnail-pipeline-gst.h
    mediaplayer.h)

set(mediaplayer_SRCS
    #thumbnail-provider.cpp
    #thumbnail-pipeline-gst.cpp
    mediaplayer.cpp
    main.cpp)

add_executable(${MEDIAPLAYER}
    ${mediaplayer_MOC_SRCS}
    ${mediaplayer_SRCS}
    )

qt5_use_modules(${MEDIAPLAYER} Gui Widgets Core Qml Quick Multimedia)

target_link_libraries(${MEDIAPLAYER}
    #${GSTLIB_LDFLAGS}
    )

install(TARGETS ${MEDIAPLAYER}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

set(QML_DIR qml)

install(DIRECTORY ${QML_DIR}
    DESTINATION ${MEDIAPLAYER_DIR}
    )

add_subdirectory(qml)
