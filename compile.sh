#!/bin/bash

set -e -u
IFS=$'\n'
renice -n 19 $$ &>/dev/null

source magiskmodule/constants.sh

GZIP=(gzip --best)
[ -n "$(command -v pigz)" ] && {
  GZIP=(pigz --best)
  [ $(nproc) -ge 8 ] && GZIP=(pigz -11)
}

[ -n "$(git status --porcelain)" ] && CHANGES="+" || CHANGES="-"
VERSIONCODE=$(git rev-list --count HEAD)
REPACKAGEDSTRING="repackagedhoch$VERSIONCODE"
COMMITHASH=$(git log -1 --pretty=%h)
VERSION=v$VERSIONCODE$CHANGES\($COMMITHASH\)

git clean -Xdfq magiskmodule/

cp -f README.md magiskmodule/README.md &
declare -x VERSION VERSIONCODE REPACKAGEDSTRING
envsubst < module.prop > magiskmodule/module.prop &

OUTPUT_FILE="ViPER4AndroidFX-$REPACKAGEDSTRING$CHANGES$COMMITHASH.zip"
rm -f ViPER4AndroidFX-repackaged*.zip

compressFiles() {
  local files="$(basename "$1")"
  local folder="$(dirname "$1")"
  local targetarchive="$2"
  (
    cd "$folder"
    tar -cf- $files | "${GZIP[@]}" > "../$targetarchive"
  )
}

echo "Compressing Viper IRS files..."
compressFiles ViperIRS/"*.irs" magiskmodule/"$VIPERIRSFILE" &

echo "Compressing Original VDC files..."
compressFiles OriginalVDCs/"*.vdc" magiskmodule/"$VIPERVDCFILE" &

wait

echo "Compressing Magisk Module..."
(
  cd magiskmodule
  zip -r -9 -q "../$OUTPUT_FILE" .
)

echo "Done"
