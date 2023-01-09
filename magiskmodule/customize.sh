#!/bin/bash

[ $API -lt 23 ] && abort "The system API of $API is less than the minimum api of 23!"

VIPERFXPACKAGE="com.pittvandewitt.viperfx"
SDCARD="/storage/emulated/0"
FOLDER="$SDCARD/Android/data/$VIPERFXPACKAGE/files"

# Uninstall v4a app if installed
[ -n "$(pm list packages | grep "$VIPERFXPACKAGE")" ] && pm uninstall "$VIPERFXPACKAGE" &>/dev/null

MODULEROOT="${MODPATH%/*}"
NVBASE="${MODULEROOT%/*}"
# Tell user aml is needed if applicable
FILES=$(find "$NVBASE"/modules/*/system "$MODULEROOT"/*/system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" -not -path "$NVBASE/modules/ViPER4AndroidFX/*" 2>/dev/null | sed "/ViPER4AndroidFX/d")
if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
  ui_print " "
  ui_print "   ! Conflicting audio mod found !"
  ui_print "   ! You will need to install    !"
  ui_print "   ! Audio Modification Library  !"
  ui_print " "
fi

# Create the scoped storage directory
mkdir -p "$FOLDER"

[ ! -d "$FOLDER"/DDC ] && mkdir -p "$FOLDER"/DDC 2>/dev/null
CUSTOM_VDC_FILES=$(find $SDCARD/ -name '*.vdc' -not -path "$SDCARD/Android/*" -not -path "$SDCARD/$(grep_prop id $MODPATH/module.prop)/*")
[ -n "$CUSTOM_VDC_FILES" ] && CUSTOM_VDC_FOUND=true || CUSTOM_VDC_FOUND=false
[ -z "$(ls "$FOLDER"/DDC 2>/dev/null)" ] && DDC_FOLDER_EMPTY=true || DDC_FOLDER_EMPTY=false
if [ $DDC_FOLDER_EMPTY = true ] && [ $CUSTOM_VDC_FOUND = false ]; then
  ui_print "- Copying original V4A vdcs"
  ui_print "   Note that some of these aren't that great"
  ui_print "   Check out here for better ones:"
  ui_print "   https://t.me/vdcservice"
  mkdir -p "$FOLDER"/DDC 2>/dev/null
  tar -xzf "$MODPATH"/ViperVDC.tar.gz -C "$FOLDER"/DDC
else 
  ui_print "  Skipping Viper original vdc copy"
  [ $DDC_FOLDER_EMPTY = false ] && ui_print "    the folder is not empty"
  [ $CUSTOM_VDC_FOUND = true ] && ui_print "    custom vdcs have been found"
fi
rm "$MODPATH"/vdcs.zip >/dev/null 2>&1
if [ $CUSTOM_VDC_FOUND = true ]; then
  ui_print "- Copying custom V4A vdcs"
  for file in $CUSTOM_VDC_FILES; do
    ui_print "    $file"
    cp -f "$file" "$FOLDER"/DDC
  done
fi

if [ -z "$(ls "$FOLDER"/Kernel 2>/dev/null)" ]; then
  ui_print "- Copying Viper IRS files"
  mkdir -p "$FOLDER"/Kernel 2>/dev/null
  tar -xzf "$MODPATH"/ViperIRS.tar.gz -C "$FOLDER"/Kernel
else
  ui_print "- Skipping Viper IRS copy, folder is not empty"
fi
rm "$MODPATH"/ViperIRS.zip 2>/dev/null

ui_print "- Patching system audio files"
AUDIO_EFFECTS_FILES="$(find /system /vendor -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml")"
for ORIGINAL_FILE in $AUDIO_EFFECTS_FILES; do
  ui_print "    Patching $ORIGINAL_FILE"
  FILE="$MODPATH$(echo "$ORIGINAL_FILE" | sed "s|^/vendor|/system/vendor|g")"
  mkdir -p "$(dirname $FILE)"
  cp "$ORIGINAL_FILE" "$FILE"
  case "$FILE" in
    *.conf) 
      sed -i "/v4a_standard_fx {/,/}/d" "$FILE"
      sed -i "/v4a_fx {/,/}/d" "$FILE"
      sed -i "s/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g" "$FILE"
      sed -i "s/^libraries {/libraries {\n  v4a_fx {\n    path $LIBPATCH\/lib\/soundfx\/libv4a_fx.so\n  }/g" "$FILE"
      ;;
    *.xml) 
      sed -i "/v4a_standard_fx/d" "$FILE"
      sed -i "/v4a_fx/d" "$FILE"
      sed -i "/<libraries>/ a\        <library name=\"v4a_fx\" path=\"libv4a_fx.so\"\/>" "$FILE"
      sed -i "/<effects>/ a\        <effect name=\"v4a_standard_fx\" library=\"v4a_fx\" uuid=\"41d3c987-e6cf-11e3-a88a-11aba5d5c51b\"\/>" "$FILE"
      ;;
  esac
done

AUDIOFX_PACKAGE="org.lineageos.audiofx"
if [ -n "$(pm list packages | grep "$AUDIOFX_PACKAGE")" ]; then
  ui_print "- Disabling $AUDIOFX_PACKAGE"
  if [ -n "$(pm list packages -d | grep "$AUDIOFX_PACKAGE")" ]; then
    ui_print"    $AUDIOFX_PACKAGE is already disabled"
  else 
    pm disable "$AUDIOFX_PACKAGE"
  fi
fi

ui_print "- Installing the ViPER4AndroidFX user app"
APK_INSTALL_FOLDER="/data/local"
(
  cp -f "$MODPATH"/v4afx.apk "$APK_INSTALL_FOLDER"/v4afx.apk || exit 1
  pm install "$APK_INSTALL_FOLDER"/v4afx.apk &>/dev/null
  RET=$?
  rm "$APK_INSTALL_FOLDER"/v4afx.apk
  exit $RET
) || abort "Failed to install V4AFX!"
pm disable "$VIPERFXPACKAGE" &>/dev/null

ui_print "- Configuring ViPER4Android"
VIPERFXPREFS="$(pm dump "$VIPERFXPACKAGE" | grep dataDir | head -n 1 | cut -d'=' -f2)"
VIPERFXPREFSOWNER="$(stat -c '%U' "$VIPERFXPREFS")"
VIPERFXSHAREDPREFS="$VIPERFXPREFS"/shared_prefs
[ ! -d "$VIPERFXSHAREDPREFS" ] && mkdir "$VIPERFXSHAREDPREFS"
cp -f "$MODPATH"/viperfx_preferences.xml "$VIPERFXSHAREDPREFS"/"${VIPERFXPACKAGE}_preferences.xml"
chown -R $VIPERFXPREFSOWNER:$VIPERFXPREFSOWNER "$VIPERFXPREFS"
chown -R $VIPERFXPREFSOWNER "$FOLDER"

ui_print "- Setting Permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH"/system/vendor 0 0 0755 0644 u:object_r:vendor_file:s0  
[ -d "$MODPATH"/system/vendor/etc ] && set_perm_recursive "$MODPATH"/system/vendor/etc 0 0 0755 0644 u:object_r:vendor_configs_file:s0
