#!/bin/bash
# 100% Pure Hyprland-Native Display Projection Handler
# Uses compositor Lua API (hl.monitor & hl.dispatch) for rock-solid stability

ACTION="$1"

# Identify internal display
INTERNAL=$(hyprctl monitors all -j 2>/dev/null | jq -r '.[] | select(.name | startswith("eDP")) | .name' 2>/dev/null | head -n 1)
[ -z "$INTERNAL" ] && INTERNAL="eDP-1"

# Identify first external display
EXTERNAL=$(hyprctl monitors all -j 2>/dev/null | jq -r --arg int "$INTERNAL" '.[] | select(.name != $int) | .name' 2>/dev/null | head -n 1)

# Preferred external resolution
EXT_MODE="1920x1080@60"

case "$ACTION" in
    internal)
        # 1. PC Screen Only: Disable external display, enable internal display at 0x0
        if [ -n "$EXTERNAL" ]; then
            hyprctl eval "hl.monitor({output = '$EXTERNAL', mirror = '', disabled = true})" 2>/dev/null || true
        fi
        hyprctl eval "hl.monitor({output = '$INTERNAL', mode = 'preferred', position = '0x0', scale = 1, mirror = '', disabled = false})" 2>/dev/null || true
        
        # Migrate all workspaces back to internal screen
        for ws in $(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id'); do
            hyprctl eval "hl.dispatch(hl.dsp.workspace.move({ workspace = $ws, monitor = '$INTERNAL' }))" 2>/dev/null || true
        done
        hyprctl eval "hl.dispatch(hl.dsp.focus({ workspace = 1 }))" 2>/dev/null || true
        ;;

    duplicate)
        # 2. Duplicate: Native compositor mirror (clones eDP-1 onto external at 1080p signal)
        if [ -n "$EXTERNAL" ]; then
            hyprctl eval "hl.monitor({output = '$INTERNAL', mode = 'preferred', position = '0x0', scale = 1, mirror = '', disabled = false}); hl.monitor({output = '$EXTERNAL', mode = '$EXT_MODE', position = 'auto', scale = 1, mirror = '$INTERNAL', disabled = false})" 2>/dev/null || true
        else
            notify-send "Project Display" "No external display detected to duplicate." -i video-display -t 3000
        fi
        ;;

    extend)
        # 3. Extend: Internal at 0x0, External placed to the right in 1080p, explicitly clearing mirror
        hyprctl eval "hl.monitor({output = '$INTERNAL', mode = 'preferred', position = '0x0', scale = 1, mirror = '', disabled = false})" 2>/dev/null || true
        if [ -n "$EXTERNAL" ]; then
            hyprctl eval "hl.monitor({output = '$EXTERNAL', mode = '$EXT_MODE', position = 'auto', scale = 1, mirror = '', disabled = false})" 2>/dev/null || true
        fi
        ;;

    second)
        # 4. Second Screen Only: External at 0x0 in 1080p, internal disabled, clearing mirror
        if [ -n "$EXTERNAL" ]; then
            hyprctl eval "hl.monitor({output = '$EXTERNAL', mode = '$EXT_MODE', position = '0x0', scale = 1, mirror = '', disabled = false}); hl.monitor({output = '$INTERNAL', mirror = '', disabled = true})" 2>/dev/null || true
            
            # Migrate all workspaces to the external screen
            for ws in $(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id'); do
                hyprctl eval "hl.dispatch(hl.dsp.workspace.move({ workspace = $ws, monitor = '$EXTERNAL' }))" 2>/dev/null || true
            done
            hyprctl eval "hl.dispatch(hl.dsp.focus({ workspace = 1 }))" 2>/dev/null || true
        else
            notify-send "Project Display" "No external display detected." -i video-display -t 3000
        fi
        ;;
esac

# Refresh Quickshell so UI layers re-attach cleanly
(
    sleep 0.4
    pkill -x qs
    sleep 0.2
    qs -c ii -d
) &>/dev/null &
