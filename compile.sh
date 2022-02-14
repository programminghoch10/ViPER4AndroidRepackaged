#!/bin/bash
OUTPUT_FILE="ViPER4Android-repackagedhoch10.zip"
[ -f "$OUTPUT_FILE" ] && rm -v "$OUTPUT_FILE"
cd magiskmodule
zip -r -9 "../$OUTPUT_FILE" .
cd ..
