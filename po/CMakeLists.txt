project(mediaplayer-translations)

include(FindGettext)

set(DOMAIN mediaplayer-app)
set(POT_FILE ${DOMAIN}.pot)
file(GLOB PO_FILES *.po)
file(GLOB_RECURSE I18N_SRCS RELATIVE ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src/*.cpp
    ${CMAKE_SOURCE_DIR}/src/*.qml)
list(APPEND I18N_SRCS data/${DESKTOP_FILE}.in.in)
list(SORT I18N_SRCS)
message("Found ${I18N_SRCS}")

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
    add_custom_target(${POT_FILE} ALL
                  COMMENT "Generating translation template"
                  COMMAND ${INTLTOOL_EXTRACT} --update --type=gettext/ini
                          --srcdir=${CMAKE_SOURCE_DIR} data/${DESKTOP_FILE}.in.in
                  COMMAND ${XGETTEXT_EXECUTABLE} -o mediaplayer-app.pot
                          --from-code=UTF-8
                          --c++ --qt --add-comments=TRANSLATORS
                          --keyword=tr --keyword=tr:1,2 --keyword=N_
                          --package-name=mediaplayer-app
                          --copyright-holder='Canonical Ltd.'
                          -D ${CMAKE_SOURCE_DIR} ${I18N_SRCS}
                          -D ${CMAKE_BINARY_DIR} data/${DESKTOP_FILE}.in.in
    )
endif()
