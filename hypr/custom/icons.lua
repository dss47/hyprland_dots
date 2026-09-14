local theme = "breeze"

-- Apply icon theme on startup for all toolkits
hl.on("hyprland.start", function()
    -- GTK
    os.execute("gsettings set org.gnome.desktop.interface icon-theme '" .. theme .. "'")

    -- KDE/Qt (respects QT_QPA_PLATFORMTHEME=kde)
    os.execute("kwriteconfig5 --file kdeglobals --group Icons --key Theme '" .. theme .. "'")
end)
