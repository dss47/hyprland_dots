-- Define the folder name of your cursor theme
local theme = "material_light_cursors"
local size = "32"

-- Set Environment Variables
-- Hyprland and modern apps will prioritize these
hl.env("XCURSOR_THEME", theme)
hl.env("XCURSOR_SIZE", size)
hl.env("HYPRCURSOR_THEME", theme)
hl.env("HYPRCURSOR_SIZE", size)

-- Apply theme on start via hyprctl and gsettings
hl.on("hyprland.start", function()
    -- Set the cursor for the Hyprland compositor
    os.execute("hyprctl setcursor " .. theme .. " " .. size)
    
    -- Sync GTK/GNOME settings for application consistency
    os.execute("gsettings set org.gnome.desktop.interface cursor-theme '" .. theme .. "'")
    os.execute("gsettings set org.gnome.desktop.interface cursor-size " .. size)
end)
