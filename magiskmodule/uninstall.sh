
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
