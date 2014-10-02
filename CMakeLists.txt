project(media-player)
cmake_minimum_required(VERSION 2.8.9)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(DESKTOP_FILE mediaplayer-app.desktop)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

find_program(INTLTOOL_MERGE intltool-merge)
find_program(INTLTOOL_EXTRACT intltool-extract)

string(TOLOWER "${CMAKE_BUILD_TYPE}" cmake_build_type_lower)

include(EnableCoverageReport)
#####################################################################
# Enable code coverage calculation with gcov/gcovr/lcov
# Usage:
#  * Switch build type to coverage (use ccmake or cmake-gui)
#  * Invoke make, make test, make coverage (or ninja if you use that backend)
#  * Find html report in subdir coveragereport
#  * Find xml report feasible for jenkins in coverage.xml
#####################################################################
if(cmake_build_type_lower MATCHES coverage)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage" )
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage" )
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} --coverage" )
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} --coverage" )
    ENABLE_COVERAGE_REPORT(TARGETS ${SHELL_APP})
endif()
find_package(Qt5Qml)
find_package(Qt5Quick)

include(FindPkgConfig)
#pkg_check_modules(GSTLIB REQUIRED gstreamer-1.0)

# Standard install paths
include(GNUInstallDirs)

set(MEDIAPLAYER_DIR ${CMAKE_INSTALL_FULL_DATADIR}/mediaplayer-app)

# for dh_translations to extract the domain
# (regarding syntax consistency, see http://pad.lv/1181187)
set (GETTEXT_PACKAGE "mediaplayer-app")

# Tests
enable_testing()

add_subdirectory(data)
add_subdirectory(src)
add_subdirectory(tests)
add_subdirectory(po)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)

