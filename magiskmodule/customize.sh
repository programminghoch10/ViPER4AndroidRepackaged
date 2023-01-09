#!/bin/bash

[ $API -lt 23 ] && abort "The system API of $API is less than the minimum api of 23!"

NEWFOL="/storage/emulated/0/Android/data/com.pittvandewitt.viperfx/files"


# Uninstall v4a app if installed
VIPERFXPACKAGE="com.pittvandewitt.viperfx"
[ -n "$(pm list packages | grep "$VIPERFXPACKAGE")" ] && pm uninstall "$VIPERFXPACKAGE" >/dev/null 2>&1

MODULEROOT=${MODPATH%/*}
NVBASE=${MODULEROOT%/*}
# Tell user aml is needed if applicable
FILES=$(find $NVBASE/modules/*/system $MODULEROOT/*/system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" -not -path "$NVBASE/modules/ViPER4AndroidFX/*" 2>/dev/null | sed "/ViPER4AndroidFX/d")
if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
  ui_print " "
  ui_print "   ! Conflicting audio mod found !"
  ui_print "   ! You will need to install    !"
  ui_print "   ! Audio Modification Library  !"
  ui_print " "
fi

# Create the new scoped storage directory
ui_print " "
ui_print "- Placing Files to New Directory:"
ui_print "  $NEWFOL"
mkdir -p $NEWFOL

[ ! -d "$NEWFOL/DDC" ] && mkdir -p "$NEWFOL/DDC" 2>/dev/null
SDCARD="/storage/emulated/0"
CUSTOM_VDC_FILES=$(find $SDCARD/ -name '*.vdc' -not -path "$SDCARD/Android/*" -not -path "$SDCARD/$(grep_prop id $MODPATH/module.prop)/*")
[ -n "$CUSTOM_VDC_FILES" ] && CUSTOM_VDC_FOUND=true || CUSTOM_VDC_FOUND=false
[ -z "$(ls "$NEWFOL/DDC" 2>/dev/null)" ] && DDC_FOLDER_EMPTY=true || DDC_FOLDER_EMPTY=false
if [ $DDC_FOLDER_EMPTY = true ] && [ $CUSTOM_VDC_FOUND = false ]; then
  ui_print " "
  ui_print "- Copying original V4A vdcs"
  ui_print " "
  ui_print "   Note that some of these aren't that great"
  ui_print "   Check out here for better ones:"
  ui_print "   https://t.me/vdcservice"
  ui_print " "
  mkdir -p "$NEWFOL/DDC" 2>/dev/null
  unzip -oj $MODPATH/vdcs.zip -d $NEWFOL/DDC >&2
else 
  ui_print " "
  ui_print "  Skipping Viper original vdc copy"
  [ $DDC_FOLDER_EMPTY = false ] && ui_print "    the folder is not empty"
  [ $CUSTOM_VDC_FOUND = true ] && ui_print "    custom vdcs have been found"
  ui_print " "
fi
rm $MODPATH/vdcs.zip >/dev/null 2>&1
if [ $CUSTOM_VDC_FOUND = true ]; then
  ui_print " "
  ui_print "- Copying custom V4A vdcs"
  ui_print " "
  ui_print "  Found these custom files:"
  ui_print "$CUSTOM_VDC_FILES"
  ui_print " "
  for file in $CUSTOM_VDC_FILES; do
    cp -fv "$file" "$NEWFOL/DDC"
  done
fi


if [ -z "$(ls "$NEWFOL/Kernel" 2>/dev/null)" ]; then
  ui_print " "
  ui_print "- Copying Viper IRS files"
  ui_print " "
  mkdir -p $NEWFOL/Kernel 2>/dev/null
  unzip -oj $MODPATH/ViperIRS.zip -d $NEWFOL/Kernel >&2
else
  ui_print " "
  ui_print "  Skipping Viper IRS copy, folder is not empty"
  ui_print " "
fi
rm $MODPATH/ViperIRS.zip >/dev/null 2>&1

# Force driver reinstall to clear out old stuff in event of change from installed version
umount -l $(mount | awk '{print $3}' | grep 'libv4a_fx.so')
killall audioserver


ui_print " "
ui_print "- Patching existing audio_effects files..."
AUDIO_EFFECTS_FILES="$(find /system /vendor -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml")"
for ORIGINAL_FILE in $AUDIO_EFFECTS_FILES; do
  ui_print "    Patching $ORIGINAL_FILE"
  FILE="$MODPATH$(echo "$ORIGINAL_FILE" | sed "s|^/vendor|/system/vendor|g")"
  mkdir -p $(dirname $FILE)
  cp -v "$ORIGINAL_FILE" "$FILE"
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
if [ -n "$(pm list packages | grep $AUDIOFX_PACKAGE)" ]; then
  ui_print " "
  ui_print "- Disabling $AUDIOFX_PACKAGE"
  if [ -n "$(pm list packages -d | grep $AUDIOFX_PACKAGE)" ]; then
    ui_print"    $AUDIOFX_PACKAGE is already disabled"
  else 
    pm disable $AUDIOFX_PACKAGE
  fi
  ui_print " "
fi

ui_print " "
ui_print "- Installing ViPER4AndroidFX $(grep_prop version $MODPATH/module.prop)..."
ui_print "   After this completes, reboot your device."
ui_print " "
APK_INSTALL_FOLDER="/data/local"
(
  cp -f "$MODPATH/v4afx.apk" "$APK_INSTALL_FOLDER/v4afx.apk" || exit 1
  pm install $APK_INSTALL_FOLDER/v4afx.apk >/dev/null 2>&1
  RET=$?
  rm "$APK_INSTALL_FOLDER/v4afx.apk"
  exit $RET
) || abort "Failed to install V4AFX!"
pm disable $VIPERFXPACKAGE >/dev/null 2>&1

ui_print " "
ui_print "- Configuring ViPER4Android"
ui_print " "
VIPERFXPREFS="$(pm dump $VIPERFXPACKAGE | grep dataDir | head -n 1 | cut -d'=' -f2)"
VIPERFXPREFSOWNER="$(stat -c '%U' "$VIPERFXPREFS")"
VIPERFXSHAREDPREFS="$VIPERFXPREFS/shared_prefs"
[ ! -d "$VIPERFXSHAREDPREFS" ] && mkdir "$VIPERFXSHAREDPREFS"
cp -f "$MODPATH/viperfx_preferences.xml" "$VIPERFXSHAREDPREFS/${VIPERFXPACKAGE}_preferences.xml"
chown -R $VIPERFXPREFSOWNER:$VIPERFXPREFSOWNER "$VIPERFXPREFS"

ui_print " "
ui_print "- Setting Permissions"
ui_print " "
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/system/vendor 0 0 0755 0644 u:object_r:vendor_file:s0  
[ -d $MODPATH/system/vendor/etc ] && set_perm_recursive $MODPATH/system/vendor/etc 0 0 0755 0644 u:object_r:vendor_configs_file:s0
