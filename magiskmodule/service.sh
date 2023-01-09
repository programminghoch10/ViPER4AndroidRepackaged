#!/bin/bash

waitUntilBootCompleted() {
  while [ $(getprop sys.boot_completed) -ne 1 ] || [ "$(getprop init.svc.bootanim | tr '[:upper:]' '[:lower:]')" != "stopped" ]; do
    sleep 1
  done
}

(
  waitUntilBootCompleted
  sleep 10
  VIPERFXPACKAGE="com.pittvandewitt.viperfx"
  [ -n "$(pm list packages -d | grep $VIPERFXPACKAGE)" ] && pm enable $VIPERFXPACKAGE
) &

(
  waitUntilBootCompleted
  sleep 60
  while true; do
    ps -A -w -o ARGS=CMD | grep -v grep | grep -q com.pittvandewitt.viperfx || am broadcast -a android.intent.action.BOOT_COMPLETED -p com.pittvandewitt.viperfx
    sleep 15
  done
) &
