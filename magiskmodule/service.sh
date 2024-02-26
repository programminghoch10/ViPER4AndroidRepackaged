#!/bin/sh

cd "$(dirname "$0")" || exit
source ./constants.sh

waitUntilBootCompleted() {
  resetprop -w sys.boot_completed 0 && return
  while [ "$(getprop sys.boot_completed)" -eq 0 ]; do
    sleep 10
  done
}

(
  waitUntilBootCompleted
  sleep 10
  pm list packages -d | grep -q "$VIPERFXPACKAGE" && pm enable "$VIPERFXPACKAGE"
) &

(
  waitUntilBootCompleted
  sleep 60
  while true; do
    PID=$(pidof "$VIPERFXPACKAGE")
    [ -z "$PID" ] && am broadcast -a android.intent.action.BOOT_COMPLETED -p "$VIPERFXPACKAGE"
    [ -n "$PID" ] && echo -1000 > /proc/"$PID"/oom_score_adj
    sleep 15
  done
) &
