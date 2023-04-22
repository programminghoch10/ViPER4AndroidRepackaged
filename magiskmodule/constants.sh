#!/bin/bash

# minimum required SDK level
MINAPI=28

# the ViPER4Android user app package
VIPERFXPACKAGE="com.pittvandewitt.viperfx"

# location of the user folder (commonly referred to as /sdcard)
SDCARD="/storage/emulated/0"

# location of the ViPER4Android app data folder
FOLDER="$SDCARD/Android/data/$VIPERFXPACKAGE/files"

# names of the included archives
VIPERVDCFILE="ViperVDC.tar.gz"
VIPERIRSFILE="ViperIRS.tar.gz"

# constants for patching system audio config files
LIBRARY_NAME="v4a_standard_fx"
EFFECT_NAME="v4a_fx"
EFFECT_UUID="41d3c987-e6cf-11e3-a88a-11aba5d5c51b"
LIBRARY_FILE="lib$EFFECT_NAME.so"
LIBRARY_FILE_PATH="/system/vendor/lib/soundfx/$LIBRARY_FILE"
