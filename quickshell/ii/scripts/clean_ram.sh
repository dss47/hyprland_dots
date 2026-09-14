#!/bin/bash
# Clean RAM cache & memory buffers instantly without dimming
sync
sudo /usr/bin/tee /proc/sys/vm/drop_caches <<< "3" >/dev/null 2>&1 || true
notify-send "RAM Purged" "Memory cache cleared successfully" -i "dialog-information" -a "Quickshell"
