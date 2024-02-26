
cd "$(dirname "$0")"
source ./constants.sh

waitUntilBootCompleted() {
  resetprop -w sys.boot_completed 0 && return
  while [ $(getprop sys.boot_completed) -eq 0 ]; do
    sleep 10
  done
}

(
  waitUntilBootCompleted
  sleep 10
  pm uninstall -k "$VIPERFXPACKAGE"
) &
