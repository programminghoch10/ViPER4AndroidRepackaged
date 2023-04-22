
cd "$(dirname "$0")"
source ./constants.sh

(
  while [ $(getprop sys.boot_completed) -ne 1 ] || [ "$(getprop init.svc.bootanim | tr '[:upper:]' '[:lower:]')" != "stopped" ]; do
    sleep 1
  done
  sleep 10
  pm uninstall -k "$VIPERFXPACKAGE"
) &
