#!/bin/sh
QML=${QML:-$(command -v qml6 || command -v qml)}
QT_QPA_PLATFORM=offscreen QT_MESSAGE_PATTERN="%{message}" QML_XHR_ALLOW_FILE_WRITE=1 $QML scrap.qml
