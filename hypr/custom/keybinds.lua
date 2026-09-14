hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )
hl.bind("SUPER+R", hl.dsp.exec_cmd("pkill -x qs; sleep 0.5; exec qs -c ii -d"), {description = "Reload QuickShell"} )
hl.bind("SUPER+P", hl.dsp.global("quickshell:sidebarLeftToggle"), {description = "Shell: Toggle left sidebar with display controls"} )

-- Bulletproof screenshot bindings (works across all monitor modes with zero failures)
hl.bind("Print", hl.dsp.exec_cmd("grim -o \"$(hyprctl activeworkspace -j | jq -r .monitor)\" - 2>/dev/null | wl-copy || grim - | wl-copy"), { locked = true, description = "Screenshot >> clipboard" })
hl.bind("CTRL+Print", hl.dsp.exec_cmd("mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim \"$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date +%Y-%m-%d_%H.%M.%S).png\" && notify-send '📸 Screenshot' 'Saved to Screenshots' -a 'Hyprland'"), { locked = true, description = "Screenshot >> file" })
hl.bind("SUPER+SHIFT+S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy && notify-send '✂️ Snip' 'Copied to clipboard' -a 'Hyprland'"), { locked = true, description = "Screen Snip >> clipboard" })

local is_gaming_mode = false
hl.bind("SUPER+F1", function()
    is_gaming_mode = not is_gaming_mode
    if is_gaming_mode then
        hl.config({ input = { repeat_delay = 10, repeat_rate = 10 } })
        hl.exec_cmd("notify-send '🎮 Gaming Mode' 'Repeat Delay: 10ms | Rate: 10' -a 'Hyprland'")
    else
        hl.config({ input = { repeat_delay = 200, repeat_rate = 30 } })
        hl.exec_cmd("notify-send '⌨️ Normal Mode' 'Repeat Delay: 200ms | Rate: 30' -a 'Hyprland'")
    end
end, { description = "Toggle Gaming Mode Repeat Rate" })

hl.bind("ALT+R", hl.dsp.exec_cmd("/home/saad/.local/bin/whisper-type"), {description = "Toggle Voice Recording (Groq Whisper)"} )
