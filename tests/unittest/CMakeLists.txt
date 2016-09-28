add_definitions(-DTEST_SUITE)

if(NOT CTEST_TESTING_TIMEOUT)
    set(CTEST_TESTING_TIMEOUT 60)
endif()

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

if(QMLTESTRUNNER_BIN AND XVFB_RUN_BIN)
    declare_qml_test("video_player" tst_video_player.qml)
else()
    if (NOT QMLTESTRUNNER_BIN)
        message(WARNING "Qml tests disabled: qmltestrunner not found")
    else()
        message(WARNING "Qml tests disabled: xvfb-run not found")
    endif()
endif()

