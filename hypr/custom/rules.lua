-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- Force settings to tile
hl.window_rule({match = {title = "^(illogical-impulse Settings)$"}, tile = true})

-- Keep Geometry Dash floating and enable immediate tearing presentation
hl.window_rule({
    match = {
        title = "^(Geometry Dash)$"
    },
    float = true,
    stay_focused = true,
    confine_pointer = true,
    immediate = true,
    no_shadow = true
})
hl.window_rule({match = {class = "^(steam_app_default)$"}, immediate = true, no_shadow = true})

-- Gaming performance: disable compositing for game windows
-- Dim is already globally disabled via dim_inactive = false in general.lua
hl.window_rule({match = {class = "^(Lutris)$"}, no_shadow = true})
hl.window_rule({match = {class = "^(gamescope)$"}, no_shadow = true, immediate = true})
hl.window_rule({match = {class = "^(steam)$"}, no_shadow = true})
hl.window_rule({match = {class = "^(Steam)$"}, no_shadow = true})
hl.window_rule({match = {class = "^(steam_app).*"}, no_shadow = true})
hl.window_rule({match = {class = "^(heroic)$"}, no_shadow = true})
hl.window_rule({match = {class = "^(HeroicGamesLauncher)$"}, no_shadow = true})
hl.window_rule({match = {class = "^(bottles)$"}, no_shadow = true})
hl.window_rule({match = {class = "^(Bottles)$"}, no_shadow = true})

-- Game engines and Wine/Proton
hl.window_rule({match = {class = "^(wine)"}, no_shadow = true, immediate = true})
hl.window_rule({match = {class = "^(Wine)"}, no_shadow = true, immediate = true})
hl.window_rule({match = {class = "^(Unity-).*"}, no_shadow = true})
hl.window_rule({match = {class = "^(Unreal).*"}, no_shadow = true})
hl.window_rule({match = {class = "^(Godot).*"}, no_shadow = true})
hl.window_rule({match = {class = "^(UnrealEngine).*"}, no_shadow = true})

-- Custom app transparency
hl.window_rule({match = {class = "^(org\\.gnome\\.Nautilus)$"}, opacity = "0.95 0.85"})
hl.window_rule({match = {class = "^(code)$"}, opacity = "0.96 0.90"})
hl.window_rule({match = {class = "^(kitty)$"}, opacity = "0.92 0.82"})
