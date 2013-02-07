project(media-player)
cmake_minimum_required(VERSION 2.8.9)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

find_package(Qt5Qml)
find_package(Qt5Quick)

include(FindPkgConfig)
pkg_check_modules(GSTLIB REQUIRED gstreamer-0.10)

# Standard install paths
include(GNUInstallDirs)

set(MEDIAPLAYER_DIR ${CMAKE_INSTALL_DATADIR}/media-player)

add_subdirectory(data)
add_subdirectory(sdk)
add_subdirectory(src)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)
