#!/bin/bash
OUTPUT_FILE="ViPER4Android-repackagedhoch10.zip"
[ -f "$OUTPUT_FILE" ] && rm -v "$OUTPUT_FILE"
cd ViperIRS
[ -f "../magiskmodule/common/ViperIRS.zip" ] && rm "../magiskmodule/common/ViperIRS.zip"
zip -9 "../magiskmodule/common/ViperIRS.zip" *.irs
cd ..
cd magiskmodule
zip -r -9 "../$OUTPUT_FILE" .
cd ..
