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

set(MEDIAPLAYER_APP_DIR ${CMAKE_INSTALL_DATADIR}/media-player)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    )

set(MEDIAPLAYER_APP media-player)

set(mediaplayer_HDRS
    mediaplayer.h)

set(mediaplayer_SRCS
    mediaplayer.cpp
    main.cpp)

add_executable(${MEDIAPLAYER_APP}
    ${mediaplayer_MOC_SRCS}
    ${mediaplayer_SRCS}
    )

qt5_use_modules(${MEDIAPLAYER_APP} Qml Quick Multimedia)

target_link_libraries(${MEDIAPLAYER_APP}
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    )

install(TARGETS ${MEDIAPLAYER_APP}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

file(GLOB QML_JS_FILES *.js *.qml)

install(FILES ${QML_JS_FILES}
    DESTINATION ${MEDIAPLAYER_APP_DIR}
    )
