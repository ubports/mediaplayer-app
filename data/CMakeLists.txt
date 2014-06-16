set(MEDIAPLAYER_DESKTOP_FILE mediaplayer-app.desktop)
set(MEDIAPLAYER_APP_ICON mediaplayer-app.svg)

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)
add_custom_target(${DESKTOP_FILE} ALL
         COMMENT "Merging translations into ${DESKTOP_FILE}"
         COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE} >/dev/null
        )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${MEDIAPLAYER_DESKTOP_FILE}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )

install(FILES ${MEDIAPLAYER_APP_ICON}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps
    )
