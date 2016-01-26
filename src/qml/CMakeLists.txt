# make the files visible on qtcreator
file(GLOB_RECURSE QML_JS_FILES *.js *.qml)
add_custom_target(mediaplayer_app_QmlFiles ALL SOURCES ${QML_JS_FILES})

