#!/bin/bash

cd "$(dirname "$0")"
source ./constants.sh

waitUntilBootCompleted() {
  while [ $(getprop sys.boot_completed) -ne 1 ] || [ "$(getprop init.svc.bootanim | tr '[:upper:]' '[:lower:]')" != "stopped" ]; do
    sleep 10
  done
}

(
  waitUntilBootCompleted
  sleep 10
  [ -n "$(pm list packages -d | grep $VIPERFXPACKAGE)" ] && pm enable $VIPERFXPACKAGE
) &

(
  waitUntilBootCompleted
  sleep 60
  while true; do
    PID=$(pidof $VIPERFXPACKAGE)
    [ -z "$PID" ] && am broadcast -a android.intent.action.BOOT_COMPLETED -p $VIPERFXPACKAGE
    [ -n "$PID" ] && echo -1000 > /proc/$PID/oom_score_adj
    sleep 15
  done
) &
