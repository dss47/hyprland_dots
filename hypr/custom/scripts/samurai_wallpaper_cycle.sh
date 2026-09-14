#!/usr/bin/env bash

# Loop through the aligned wallpapers every 5 minutes (300s)
while true; do
    for img in "$HOME/Pictures/Wallpapers/Samurai_Cycle/"*.png; do
        "$HOME/.config/quickshell/ii/scripts/colors/switchwall.sh" --image "$img"
        sleep 4
    done
done
