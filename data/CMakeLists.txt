set(MEDIAPLAYER_DESKTOP_FILE media-player.desktop)
set(MEDIAPLAYER_APP_ICON media-player.svg)

install(FILES ${MEDIAPLAYER_DESKTOP_FILE}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )

install(FILES ${MEDIAPLAYER_APP_ICON}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps
    )
