# Saad's Arch Linux Hyprland Dotfiles

Arch Linux setup with Hyprland (Lua configuration), Quickshell, Kitty, and Fish shell.

## 📁 Repository Structure

- `hypr/` : Hyprland WM configuration (`hyprland.lua`, `custom/`, keybinds, rules, `hyprlock`, `hypridle`).
- `quickshell/` : Quickshell UI desktop widgets, top bar, dashboard (`ii`).
- `kitty/` : Kitty terminal emulator configuration.
- `fish/` : Fish shell configuration, completions, and functions.
- `pkglist/` :
  - `pacman_explicit.txt` : List of explicitly installed official packages.
  - `aur_explicit.txt` : List of explicitly installed AUR packages.

## 🚀 Restoration on a Fresh System

### 1. Install Packages
```bash
# Official packages
sudo pacman -S --needed - < pkglist/pacman_explicit.txt

# AUR packages (using yay or paru)
yay -S --needed - < pkglist/aur_explicit.txt
```

### 2. Restore Configurations
```bash
cp -r hypr ~/.config/
cp -r quickshell ~/.config/
cp -r kitty ~/.config/
cp -r fish ~/.config/
```
