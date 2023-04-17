#!/bin/bash

[ $API -lt 28 ] && abort "Android SDK $API is not supported!"

VIPERFXPACKAGE="com.pittvandewitt.viperfx"
SDCARD="/storage/emulated/0"
FOLDER="$SDCARD/Android/data/$VIPERFXPACKAGE/files"
VIPERVDCFILE="ViperVDC.tar.gz"
VIPERIRSFILE="ViperIRS.tar.gz"

IFS=$'\n'
SEARCH_ROOT="$(magisk --path)/.magisk/mirror"/
[ ! -d "$SEARCH_ROOT" ] && SEARCH_ROOT=/

rmi() {
  local file="$1"
  [ -f "$file" ] && rm "$file"
}

# Create the scoped storage directory
mkdir -p "$FOLDER"

mkdir -p "$FOLDER"/DDC
CUSTOM_VDC_FILES=$(find $SDCARD -name '*.vdc' -not -path "$SDCARD/Android/*")
[ -n "$CUSTOM_VDC_FILES" ] && CUSTOM_VDC_FOUND=true || CUSTOM_VDC_FOUND=false
[ -f "$MODPATH"/"$VIPERVDCFILE" ] && ORIGINAL_VDC_ARCHIVE_FOUND=true || ORIGINAL_VDC_ARCHIVE_FOUND=false
for file in $(tar -tzf "$MODPATH"/"$VIPERVDCFILE") $CUSTOM_VDC_FILES; do
  file="$FOLDER"/DDC/"$file"
  rmi "$file"
done
[ -z "$(ls -A "$FOLDER"/DDC 2>/dev/null)" ] && VDC_FOLDER_EMPTY=true || VDC_FOLDER_EMPTY=false
if $VDC_FOLDER_EMPTY && ! $CUSTOM_VDC_FOUND && $ORIGINAL_VDC_ARCHIVE_FOUND; then
  ui_print "- Copying original ViPER4Android VDCs"
  ui_print "   Note that some of these aren't that great"
  ui_print "   Check out https://t.me/vdcservice for better ones"
  mkdir -p "$FOLDER"/DDC 2>/dev/null
  tar -xzf "$MODPATH"/"$VIPERVDCFILE" -C "$FOLDER"/DDC
else
  ui_print "- Skipping Viper original VDC copy"
  ! $VDC_FOLDER_EMPTY && ui_print "    the folder is not empty"
  $CUSTOM_VDC_FOUND && ui_print "    custom VDCs have been found"
  ! $ORIGINAL_VDC_ARCHIVE_FOUND && ui_print "    the required data couldn't be located"
fi
rmi "$MODPATH"/"$VIPERVDCFILE"
if $CUSTOM_VDC_FOUND; then
  ui_print "- Copying custom VDCs"
  for file in $CUSTOM_VDC_FILES; do
    ui_print "    $file"
    cp -f "$file" "$FOLDER"/DDC
  done
fi

mkdir -p "$FOLDER"/Kernel
CUSTOM_IRS_FILES=$(find $SDCARD -name '*.irs' -not -path "$SDCARD/Android/*")
[ -n "$CUSTOM_IRS_FILES" ] && CUSTOM_IRS_FOUND=true || CUSTOM_IRS_FOUND=false
[ -f "$MODPATH"/"$VIPERIRSFILE" ] && IRS_ARCHIVE_FOUND=true || IRS_ARCHIVE_FOUND=false
for file in $(tar -tzf "$MODPATH"/"$VIPERIRSFILE") $CUSTOM_IRS_FILES; do
  file="$FOLDER"/Kernel/"$file"
  rmi "$file"
done
[ -z "$(ls -A "$FOLDER"/Kernel 2>/dev/null)" ] && IRS_FOLDER_EMPTY=true || IRS_FOLDER_EMPTY=false
if $IRS_FOLDER_EMPTY && ! $CUSTOM_IRS_FOUND && $IRS_ARCHIVE_FOUND; then
  ui_print "- Copying Viper IRS files"
  mkdir -p "$FOLDER"/Kernel 2>/dev/null
  tar -xzf "$MODPATH"/"$VIPERIRSFILE" -C "$FOLDER"/Kernel
else
  ui_print "- Skipping Viper IRS copy"
  ! $IRS_FOLDER_EMPTY && ui_print "    the folder is not empty"
  $CUSTOM_IRS_FOUND && ui_print "    custom IRS files have been found"
  ! $IRS_ARCHIVE_FOUND && ui_print "    the required data couldn't be located"
fi
rmi "$MODPATH"/"$VIPERIRSFILE"
if $CUSTOM_IRS_FOUND; then
  ui_print "- Copying custom IRS files"
  for file in $CUSTOM_IRS_FILES; do
    ui_print "    $file"
    cp -f "$file" "$FOLDER"/Kernel
  done
fi

ui_print "- Patching system audio files"
LIBRARY_NAME="v4a_standard_fx"
EFFECT_NAME="v4a_fx"
EFFECT_UUID="41d3c987-e6cf-11e3-a88a-11aba5d5c51b"
LIBRARY_FILE="lib$EFFECT_NAME.so"
LIBRARY_FILE_PATH="/system/vendor/lib/soundfx/$LIBRARY_FILE"
AUDIO_EFFECTS_FILES="$( \
  find -H \
  $SEARCH_ROOT/system $SEARCH_ROOT/vendor $SEARCH_ROOT/odm \
  -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" \
  | sed "s|^$SEARCH_ROOT||" )"
for ORIGINAL_FILE in $AUDIO_EFFECTS_FILES; do
  ui_print "    Patching $ORIGINAL_FILE"
  FILE="$MODPATH"/"$(echo "$ORIGINAL_FILE" | sed -e 's|^/system/|/|g' -e 's|^/|/system/|')"
  [ -f "$FILE" ] && continue
  mkdir -p "$(dirname $FILE)"
  ORIGINAL_FILE="$SEARCH_ROOT"/"$ORIGINAL_FILE"
  case "$FILE" in
    *.conf)
      sed \
        -e "s|^effects {|effects {\n  $LIBRARY_NAME {\n    library $EFFECT_NAME\n    uuid $EFFECT_UUID\n  }|" \
        -e "s|^libraries {|libraries {\n  $EFFECT_NAME {\n    path $LIBRARY_FILE_PATH\n  }|" \
        < "$ORIGINAL_FILE" > "$FILE"
      ;;
    *.xml)
      sed \
        -e "s|<libraries>|<libraries>\n        <library name=\"$EFFECT_NAME\" path=\"$LIBRARY_FILE\"/>|" \
        -e "s|<effects>|<effects>\n        <effect name=\"$LIBRARY_NAME\" library=\"$EFFECT_NAME\" uuid=\"$EFFECT_UUID\"/>|" \
        < "$ORIGINAL_FILE" > "$FILE"
      ;;
  esac
done

ui_print "- Installing the ViPER4AndroidFX user app"
APK="$MODPATH"/v4afx.apk
[ ! -f "$APK" ] && abort "Missing ViPER4Android APK!"
[ -n "$(pm list packages | grep "^package:$VIPERFXPACKAGE$")" ] && APK_UPGRADE=true || APK_UPGRADE=false
APK_SIZE=$(stat -c %s "$APK")
installAPK() {
  pm install --install-location 1 --pkg "$VIPERFXPACKAGE" -S $APK_SIZE < "$APK" &>/dev/null
}
installAPK || {
  $APK_UPGRADE && pm uninstall -k "$VIPERFXPACKAGE" &>/dev/null
  APK_UPGRADE=false
  installAPK
} || abort "Failed to install V4AFX!"
! $APK_UPGRADE && pm disable "$VIPERFXPACKAGE" &>/dev/null

ui_print "- Configuring ViPER4Android"
VIPERFXPREFS="$(pm dump "$VIPERFXPACKAGE" | grep dataDir | head -n 1 | cut -d'=' -f2)"
VIPERFXPREFSOWNER="$(stat -c '%U' "$VIPERFXPREFS")"
VIPERFXSHAREDPREFS="$VIPERFXPREFS"/shared_prefs
[ ! -d "$VIPERFXSHAREDPREFS" ] && mkdir "$VIPERFXSHAREDPREFS"
cp -f "$MODPATH"/viperfx_preferences.xml "$VIPERFXSHAREDPREFS"/"${VIPERFXPACKAGE}_preferences.xml"
chown -R $VIPERFXPREFSOWNER:$VIPERFXPREFSOWNER "$VIPERFXPREFS"
set_perm_recursive "$FOLDER" "$VIPERFXPREFSOWNER" sdcard_rw 771 660 u:object_r:sdcardfs:s0
# this permanently hides the notifications without the possiblity of reenabling them
[ $API -ge 31 ] && pm set-distracting-restriction --flag hide-notifications $VIPERFXPACKAGE
[ $API -ge 33 ] && {
  # this will tell android that the user made the final decision to not receive notifications
  pm revoke $VIPERFXPACKAGE android.permission.POST_NOTIFICATIONS
  pm set-permission-flags $VIPERFXPACKAGE android.permission.POST_NOTIFICATIONS user-fixed
}
# this disables battery optimization
[ $API -ge 30 ] && dumpsys deviceidle whitelist +$VIPERFXPACKAGE >/dev/null

for packagedata in $(sed -e 's/^\s*#.*$//' -e '/^$/d' < "$MODPATH"/stockeqpackages.csv); do
  package="$(echo "$packagedata" | cut -d'|' -f1)"
  package_filename="$(echo "$packagedata" | cut -d'|' -f2)"
  package_friendlyname="$(echo "$packagedata" | cut -d'|' -f3)"
  [ -n "$(pm list packages | grep "^package:$package$")" ] && {
    ui_print "- Disabling $package_friendlyname (p)"
    package_apk="$(pm list packages -f $package | grep -E "package:.*=$package$" | sed "s/package:\(.*\)=$package/\1/")"
    package_apk_dir="$(dirname "$package_apk" | sed -e 's|^/||' -e 's|^system/||')"
    mkdir -p "$MODPATH"/system/"$package_apk_dir"
    touch "$MODPATH"/system/"$package_apk_dir"/"$(basename "$package_apk")"
    continue
  }
  package_apk_files="$(find -H \
      $SEARCH_ROOT/system $SEARCH_ROOT/system_ext $SEARCH_ROOT/vendor $SEARCH_ROOT/product \
      -type f -name "$package_filename" \
      | sed -e "s|^$SEARCH_ROOT||" -e 's|^/system/|/|' \
      | uniq )"
  [ -n "$package_apk_files" ] && {
    ui_print "- Disabling $package_friendlyname (f)"
    for package_apk in $package_apk_files; do
      package_apk_dir="$(dirname "$package_apk" | sed -e 's|^/||' -e 's|^system/||')"
      mkdir -p "$MODPATH"/system/"$package_apk_dir"
      touch "$MODPATH"/system/"$package_apk_dir"/"$(basename "$package_apk")"
    done
  }
done

ui_print "- Setting Permissions"
set_perm_recursive "$MODPATH"/system root root 755 644
set_perm_recursive "$MODPATH"/system/vendor root root 755 644 u:object_r:vendor_file:s0
[ -d "$MODPATH"/system/vendor/etc ] && set_perm_recursive "$MODPATH"/system/vendor/etc root root 755 644 u:object_r:vendor_configs_file:s0
