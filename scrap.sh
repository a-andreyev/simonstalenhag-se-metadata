#!/bin/sh
QT_MESSAGE_PATTERN="%{message}" qml scrap.qml &> results.json
