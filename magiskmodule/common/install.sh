
[ "`getenforce`" == "Enforcing" ] && ENFORCE=true || ENFORCE=false
NEWFOL="/storage/emulated/0/Android/data/com.pittvandewitt.viperfx/files"

# Uninstall v4a app if installed
VIPERFXPACKAGE="com.pittvandewitt.viperfx"
[ -n "$(pm list packages | grep "$VIPERFXPACKAGE")" ] && pm uninstall "$VIPERFXPACKAGE" >/dev/null 2>&1

# Tell user aml is needed if applicable
FILES=$(find $NVBASE/modules/*/system $MODULEROOT/*/system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" -not -path "$NVBASE/modules/ViPER4AndroidFX/*" 2>/dev/null | sed "/$MODID/d")
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


# Force driver reinstall to clear out old stuff in event of change from installed version
umount -l $(mount | awk '{print $3}' | grep 'libv4a_fx.so')
killall audioserver


ui_print " "
ui_print "- Patching audio_effects.xml"
mkdir -p $MODPATH/system/vendor/etc
AUDIO_EFFECTS_FILE=$MODPATH/system/vendor/etc/audio_effects.xml
cp -f /vendor/etc/audio_effects.xml $AUDIO_EFFECTS_FILE
sed -i "/v4a_standard_fx/d" $AUDIO_EFFECTS_FILE
sed -i "/v4a_fx/d" $AUDIO_EFFECTS_FILE
sed -i "/<libraries>/ a\        <library name=\"v4a_fx\" path=\"libv4a_fx.so\"\/>" $AUDIO_EFFECTS_FILE
sed -i "/<effects>/ a\        <effect name=\"v4a_standard_fx\" library=\"v4a_fx\" uuid=\"41d3c987-e6cf-11e3-a88a-11aba5d5c51b\"\/>" $AUDIO_EFFECTS_FILE

# here is how to strace v4a app:
#  run adb root
#  run in adb shell
#    while [ -z "$(pidof com.pittvandewitt.viperfx)" ]; do true; done && (strace -f -p $(pidof com.pittvandewitt.viperfx) 2>&1| grep -i "open")
ui_print " "
ui_print "- Installing ViPER4AndroidFX $(grep_prop version $MODPATH/module.prop)..."
ui_print "   After this completes,"
#ui_print "   open V4A app and follow the prompts"
ui_print "   you MUST REBOOT before opening the app"
#ui_print "   reboot your device."
ui_print " "
$ENFORCE && setenforce 0
(pm install $MODPATH/v4afx.apk >/dev/null 2>&1) || abort "Failed to install V4AFX!"
$ENFORCE && setenforce 1
