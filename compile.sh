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

compressArchiveZip() {
  local files="$(basename "$1")"
  local folder="$(dirname "$1")"
  local targetarchive="$(pwd)"/"$2"
  (
    cd "$folder"
    zip -r -9 -q "$targetarchive" $files
  )
}

compressArchiveTarGz() {
  local files="$(basename "$1")"
  local folder="$(dirname "$1")"
  local targetarchive="$2"
  (
    cd "$folder"
    tar -cf- $files | "${GZIP[@]}" > "../$targetarchive"
  )
}

setVersionVariables() {
  local folder="$1"
  [ -n "$(git status --porcelain -- "$folder")" ] && CHANGES="+" || CHANGES="-"
  VERSIONCODE=$(git rev-list --count HEAD -- "$folder")
  REPACKAGEDSTRING="repackagedhoch$VERSIONCODE"
  COMMITHASH=$(git log -1 --pretty=%h -- "$folder")
  VERSION=v$VERSIONCODE$CHANGES\($COMMITHASH\)
  FILENAMEVERSION=$REPACKAGEDSTRING$CHANGES$COMMITHASH
}

git clean -Xdfq magiskmodule/

setVersionVariables .

cp -f README.md magiskmodule/README.md &
declare -x VERSION VERSIONCODE REPACKAGEDSTRING
envsubst < module.prop > magiskmodule/module.prop &

OUTPUT_FILE="ViPER4AndroidFX-$FILENAMEVERSION.zip"
rm -f ViPER4AndroidFX-repackaged*.zip &

compressArchiveTarGz ViperIRS/"*.irs" magiskmodule/"$VIPERIRSFILE" &
compressArchiveTarGz ViperVDC/"*.vdc" magiskmodule/"$VIPERVDCFILE" &

wait
compressArchiveZip "magiskmodule/." "$OUTPUT_FILE"
