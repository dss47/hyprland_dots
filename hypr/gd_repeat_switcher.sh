#!/usr/bin/env bash

handle() {
    case $1 in
        activewindowv2*)
            local title
            title=$(hyprctl activewindow -j 2>/dev/null | grep -o '"title": *"[^"]*"' | cut -d'"' -f4)
            local class
            class=$(hyprctl activewindow -j 2>/dev/null | grep -o '"class": *"[^"]*"' | cut -d'"' -f4)

            if [[ "$title" == *"Geometry Dash"* ]] || [[ "$class" == *"steam_app_322170"* ]] || [[ "$class" == *"GeometryDash"* ]]; then
                # High-speed gaming mode ONLY inside Geometry Dash
                hyprctl eval 'hl.config({ input = { repeat_delay = 180, repeat_rate = 10 } })' >/dev/null 2>&1
            else
                # Clean, normal typing mode with zero double-letters for desktop/browsers
                hyprctl eval 'hl.config({ input = { repeat_delay = 350, repeat_rate = 30 } })' >/dev/null 2>&1
            fi
            ;;
    esac
}

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
