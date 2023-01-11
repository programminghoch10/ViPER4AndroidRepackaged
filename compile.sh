#!/bin/bash

set -e -u

GZIP=gzip
[ -n "$(command -v pigz)" ] && GZIP=pigz

[[ `git status --porcelain` ]] && CHANGES="+" || CHANGES="-"
VERSIONCODE=$(git rev-list --count HEAD)
REPACKAGEDSTRING="repackagedhoch$VERSIONCODE"
COMMITHASH=$(git log -1 --pretty=%h)
VERSION=v$VERSIONCODE$CHANGES\($COMMITHASH\)

cp -f module.prop magiskmodule/module.prop
cp -f README.md magiskmodule/README.md
sed -i "s/VERSION/$VERSION/g" magiskmodule/module.prop
sed -i "s/VCODE/$VERSIONCODE/g" magiskmodule/module.prop
sed -i "s/REPACKAGEDSTRING/$REPACKAGEDSTRING/g" magiskmodule/module.prop

OUTPUT_FILE="ViPER4AndroidFX-$REPACKAGEDSTRING$CHANGES$COMMITHASH.zip"
rm ViPER4AndroidFX-repackaged* 2>/dev/null || true

echo "Compressing Viper IRS files..."
cd ViperIRS
IRSFILE="../magiskmodule/ViperIRS.tar.gz"
[ -f "$IRSFILE" ] && rm "$IRSFILE"
tar -cf- *.irs | $GZIP --best > "$IRSFILE"
cd ..

echo "Compressing Original VDC files..."
cd OriginalVDCs
VDCFILE="../magiskmodule/ViperVDC.tar.gz"
[ -f "$VDCFILE" ] && rm "$VDCFILE"
tar -cf- *.vdc | $GZIP --best > "$VDCFILE"
cd ..

echo "Compressing Magisk Module..."
cd magiskmodule
zip -r -9 -q "../$OUTPUT_FILE" .
cd ..

echo "Done"
