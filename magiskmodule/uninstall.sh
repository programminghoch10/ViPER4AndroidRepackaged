
(
  while [ $(getprop sys.boot_completed) -ne 1 ] || [ "$(getprop init.svc.bootanim | tr '[:upper:]' '[:lower:]')" != "stopped" ]; do
    sleep 1
  done
  sleep 10
  AUDIOFXPACKAGE="org.lineageos.audiofx"
  [ -n "$(pm list packages -d | grep "$AUDIOFXPACKAGE")" ] && pm enable "$AUDIOFXPACKAGE"
  VIPERFXPACKAGE="com.pittvandewitt.viperfx"
  pm uninstall -k "$VIPERFXPACKAGE"
) &

# Don't modify anything after this
if [ -f $INFO ]; then
  while read LINE; do
    if [ "$(echo -n $LINE | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f $LINE~ $LINE
    else
      rm -f $LINE
      while true; do
        LINE=$(dirname $LINE)
        [ "$(ls -A $LINE 2>/dev/null)" ] && break 1 || rm -rf $LINE
      done
    fi
  done < $INFO
  rm -f $INFO
fi
