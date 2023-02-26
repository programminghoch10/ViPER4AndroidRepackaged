#!/bin/bash

set -e -u
IFS=$'\n'

GZIP=gzip
[ -n "$(command -v pigz)" ] && GZIP=pigz

[ -n "$(git status --porcelain)" ] && CHANGES="+" || CHANGES="-"
VERSIONCODE=$(git rev-list --count HEAD)
REPACKAGEDSTRING="repackagedhoch$VERSIONCODE"
COMMITHASH=$(git log -1 --pretty=%h)
VERSION=v$VERSIONCODE$CHANGES\($COMMITHASH\)

cp -f README.md magiskmodule/README.md
declare -x VERSION VERSIONCODE REPACKAGEDSTRING
envsubst < module.prop > magiskmodule/module.prop

OUTPUT_FILE="ViPER4AndroidFX-$REPACKAGEDSTRING$CHANGES$COMMITHASH.zip"
rm ViPER4AndroidFX-repackaged*.zip 2>/dev/null || true

compressFiles() {
  local files="$(basename "$1")"
  local folder="$(dirname "$1")"
  local targetarchive="$2"
  (
    cd "$folder"
    tar -cf- $files | $GZIP --best > "../$targetarchive"
  )
}

echo "Compressing Viper IRS files..."
compressFiles ViperIRS/"*.irs" magiskmodule/ViperIRS.tar.gz &

echo "Compressing Original VDC files..."
compressFiles OriginalVDCs/"*.vdc" magiskmodule/ViperVDC.tar.gz &

wait

echo "Compressing Magisk Module..."
(
  cd magiskmodule
  zip -r -9 -q "../$OUTPUT_FILE" .
)

echo "Done"
