add_custom_target(autopilot)

function(declare_autopilot_test ENVIROMENT TEST_NAME WORKING_DIR)

    add_custom_command(TARGET autopilot
        COMMAND ${ENVIROMENT} autopilot run ${TEST_NAME}
        WORKING_DIRECTORY ${WORKING_DIR}) 
endfunction()
