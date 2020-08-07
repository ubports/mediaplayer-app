set(MEDIAPLAYER_DESKTOP_FILE mediaplayer-app.desktop)
set(MEDIAPLAYER_APP_ICON mediaplayer-app.png)
set(MEDIAPLAYER_APP_SPLASH mediaplayer-app-splash.svg)
set(MEDIAPLAYER_APP_SYMBOLIC_ICON mediaplayer-app-symbolic.svg)
set(MEDIAPLAYER_URL_DISPATCHER mediaplayer-app.url-dispatcher)
set(MEDIAPLAYER_CONTENT_HUB mediaplayer-app-content.json)

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)
add_custom_target(${DESKTOP_FILE} ALL
         COMMENT "Merging translations into ${DESKTOP_FILE}"
         COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE} >/dev/null
        )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${MEDIAPLAYER_DESKTOP_FILE}
        DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
)

install(FILES ${MEDIAPLAYER_APP_ICON} ${MEDIAPLAYER_APP_SPLASH} ${MEDIAPLAYER_APP_SYMBOLIC_ICON}
        DESTINATION ${MEDIAPLAYER_DIR}
)

install(FILES ${MEDIAPLAYER_URL_DISPATCHER}
        DESTINATION ${CMAKE_INSTALL_DATADIR}/url-dispatcher/urls
)

install(FILES ${MEDIAPLAYER_CONTENT_HUB}
        DESTINATION ${CMAKE_INSTALL_DATADIR}/content-hub/peers
        RENAME mediaplayer-app)
