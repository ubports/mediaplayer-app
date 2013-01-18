project(mediaplayer_src)

set(MEDIAPLAYER media-player)

include_directories(
    ${CMAKE_BINARY_DIR}
    )

set(mediaplayer_HDRS
    mediaplayer.h)

set(mediaplayer_SRCS
    mediaplayer.cpp
    main.cpp)

add_executable(${MEDIAPLAYER}
    ${mediaplayer_MOC_SRCS}
    ${mediaplayer_SRCS}
    )

qt5_use_modules(${MEDIAPLAYER} Qml Quick Multimedia)

target_link_libraries(${MEDIAPLAYER}
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    )

install(TARGETS ${MEDIAPLAYER}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

file(GLOB QML_JS_FILES *.js *.qml)

set(QML_DIR qml)

install(DIRECTORY ${QML_DIR}
    DESTINATION ${MEDIAPLAYER_DIR}
    )
