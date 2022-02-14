# This script will be executed in late_start service mode
# More info in the main Magisk thread
(
sleep 3
killall -q audioserver
killall -q mediaserver
)&
