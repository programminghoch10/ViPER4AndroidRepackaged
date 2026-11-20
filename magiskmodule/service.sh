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

  # PackageManager may not expose the app's private data during module install.
  # Install default preferences once the normal boot namespace can see it.
  APPDATA="$(pm dump "$VIPERFXPACKAGE" | grep dataDir | head -n 1 | cut -d'=' -f2)"
  attempts=0
  while [ ! -d "$APPDATA" ] && [ "$attempts" -lt 12 ]; do
    sleep 5
    attempts=$((attempts + 1))
  done
  if [ -d "$APPDATA" ]; then
    PREFDIR="$APPDATA/shared_prefs"
    PREF="$PREFDIR/${VIPERFXPACKAGE}_preferences.xml"
    if [ ! -e "$PREF" ]; then
      mkdir -p "$PREFDIR" && cp ./viperfx_preferences.xml "$PREF" && {
        chown "$(stat -c '%u:%g' "$APPDATA")" "$PREFDIR" "$PREF"
        chmod 700 "$PREFDIR"
        chmod 600 "$PREF"
        APP_CONTEXT="$(stat -c '%C' "$APPDATA")"
        [ -n "$APP_CONTEXT" ] && chcon "$APP_CONTEXT" "$PREFDIR" "$PREF"
      }
    fi
  fi
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
