project(media-player)
cmake_minimum_required(VERSION 2.8.9)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

find_package(Qt5Qml)
find_package(Qt5Quick)

# Standard install paths
include(GNUInstallDirs)

set(MEDIAPLAYER_DIR ${CMAKE_INSTALL_DATADIR}/media-player)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    )

set(MEDIAPLAYER media-player)

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

install(FILES data/${MEDIAPLAYER}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )

install(FILES data/${MEDIAPLAYER}.svg
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps
    )
