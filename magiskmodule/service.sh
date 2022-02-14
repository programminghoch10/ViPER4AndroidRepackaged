(
  while [ $(getprop sys.boot_completed) -ne 1 ] || [ "$(getprop init.svc.bootanim | tr '[:upper:]' '[:lower:]')" != "stopped" ]; do
    sleep 1
  done
  sleep 10
  VIPERFXPACKAGE="com.pittvandewitt.viperfx"
  [ -n "$(pm list packages -d | grep $VIPERFXPACKAGE)" ] && pm enable $VIPERFXPACKAGE
) &