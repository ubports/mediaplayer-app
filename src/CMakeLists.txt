project(mediaplayer_src)

set(MEDIAPLAYER media-player)

include_directories(
    ${CMAKE_BINARY_DIR}
    ${sdkhelper_SOURCE_DIR}
    )

set(mediaplayer_HDRS
    thumbnail-surface.h
    thumbnail-provider.h
    mediaplayer.h)

set(mediaplayer_SRCS
    thumbnail-surface.cpp
    thumbnail-provider.cpp
    mediaplayer.cpp
    main.cpp)

add_executable(${MEDIAPLAYER}
    ${mediaplayer_MOC_SRCS}
    ${mediaplayer_SRCS}
    )

qt5_use_modules(${MEDIAPLAYER} Gui Core Qml Quick Multimedia)

target_link_libraries(${MEDIAPLAYER}
    sdkhelper
    )

install(TARGETS ${MEDIAPLAYER}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

file(GLOB QML_JS_FILES *.js *.qml)

set(QML_DIR qml)

install(DIRECTORY ${QML_DIR}
    DESTINATION ${MEDIAPLAYER_DIR}
    )
