project(mediaplayer-translations)

include(FindGettext)

set(DOMAIN mediaplayer-app)
set(POT_FILE ${DOMAIN}.pot)
file(GLOB PO_FILES *.po)
file(GLOB_RECURSE QML_SRCS RELATIVE ${CMAKE_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/src/*.qml)

foreach(PO_FILE ${PO_FILES})
    get_filename_component(LANG ${PO_FILE} NAME_WE)
    gettext_process_po_files(${LANG} ALL PO_FILES ${PO_FILE})
    set(INSTALL_DIR ${CMAKE_INSTALL_LOCALEDIR}/${LANG}/LC_MESSAGES)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.gmo
            DESTINATION ${INSTALL_DIR}
            RENAME ${DOMAIN}.mo)
endforeach(PO_FILE)

find_program(XGETTEXT_EXECUTABLE xgettext)
if(XGETTEXT_EXECUTABLE)
    add_custom_target(create-pot)
    add_custom_command(TARGET create-pot
        COMMAND ${XGETTEXT_EXECUTABLE} --c++ --qt --add-comments=TRANSLATORS --keyword=tr -D ${CMAKE_SOURCE_DIR} -s -kWORD=tr -p ${CMAKE_CURRENT_SOURCE_DIR} -o mediaplayer-app.pot ${QML_SRCS}
    )
endif()
