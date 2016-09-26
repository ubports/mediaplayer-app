add_definitions(-DTEST_SUITE)

if(NOT CTEST_TESTING_TIMEOUT)
    set(CTEST_TESTING_TIMEOUT 60)
endif()

include_directories(${CMAKE_BINARY_DIR}
                    ${mediaplayer_src_SOURCE_DIR}
                    ${GSTLIB_INCLUDE_DIRS}
)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/test-config.h.in
               ${CMAKE_CURRENT_BINARY_DIR}/test-config.h)

# thumbnail-test ##############################################################
#add_executable(thumbnailtest
#               thumbnailtest.cpp
#               ${mediaplayer_src_SOURCE_DIR}/thumbnail-pipeline-gst.cpp
#)

#qt5_use_modules(thumbnailtest Gui Core Test)
#add_test(thumbnailtest thumbnailtest -xunitxml -o test_thumbnailtest.xml)
#set_tests_properties(thumbnailtest PROPERTIES
#                     TIMEOUT ${CTEST_TESTING_TIMEOUT}
#                     ENVIRONMENT "QT_QPA_PLATFORM=minimal")
#target_link_libraries(thumbnailtest
#                      ${GSTLIB_LDFLAGS})
###############################################################################


find_program(QMLTESTRUNNER_BIN
    NAMES qmltestrunner
    PATHS /usr/lib/*/qt5/bin
    NO_DEFAULT_PATH
)

find_program(XVFB_RUN_BIN
    NAMES xvfb-run
)

macro(DECLARE_QML_TEST TST_NAME TST_QML_FILE)
    if(USE_XVFB)
        set(COMMAND_PREFIX ${XVFB_RUN_BIN} -a -s "-screen 0 1024x768x24")
    else()
        set(COMMAND_PREFIX "")
    endif()
    add_test(NAME ${TST_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMAND ${COMMAND_PREFIX} ${QMLTESTRUNNER_BIN} -input ${CMAKE_CURRENT_SOURCE_DIR}/${TST_QML_FILE}
    )
endmacro()

declare_qml_test("video_player" tst_video_player.qml)
