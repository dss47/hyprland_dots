#!/usr/bin/env bash

QUICKSHELL_CONFIG_NAME="ii"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

term_alpha=100 #Set this to < 100 make all your terminals transparent
# sleep 0 # idk i wanted some delay or colors dont get applied properly
if [ ! -d "$STATE_DIR"/user/generated ]; then
  mkdir -p "$STATE_DIR"/user/generated
fi
cd "$CONFIG_DIR" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

colornames=$(cat $STATE_DIR/user/generated/material_colors.scss | cut -d: -f1)
colorstrings=$(cat $STATE_DIR/user/generated/material_colors.scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
IFS=$'\n'
colorlist=($colornames)     # Array of color names
colorvalues=($colorstrings) # Array of color values

apply_kitty() {  
  if [ ! -f "$SCRIPT_DIR/terminal/kitty-theme.conf" ]; then
    echo "Template file not found for Kitty theme. Skipping that."
    return
  fi
  mkdir -p "$STATE_DIR"/user/generated/terminal
  cp "$SCRIPT_DIR/terminal/kitty-theme.conf" "$STATE_DIR"/user/generated/terminal/kitty-theme.conf

  python3 -c "
import sys
state_dir = sys.argv[1]
target = sys.argv[2]

colors = {}
with open(f'{state_dir}/user/generated/material_colors.scss') as f:
    for line in f:
        if ':' in line:
            k, v = line.strip().split(':', 1)
            colors['#' + k.strip() + ' #'] = v.strip().strip(';').strip()

with open(target) as f:
    content = f.read()
for k, v in colors.items():
    content = content.replace(k, v)
with open(target, 'w') as f:
    f.write(content)
" "$STATE_DIR" "$STATE_DIR/user/generated/terminal/kitty-theme.conf"

  if ! pgrep -f kitty >/dev/null; then
    return
  fi
  kill -SIGUSR1 $(pidof kitty) 2>/dev/null || true
}

apply_anyterm() {
  if [ ! -f "$SCRIPT_DIR/terminal/sequences.txt" ]; then
    echo "Template file not found for Terminal. Skipping that."
    return
  fi
  mkdir -p "$STATE_DIR"/user/generated/terminal
  cp "$SCRIPT_DIR/terminal/sequences.txt" "$STATE_DIR"/user/generated/terminal/sequences.txt

  python3 -c "
import sys
state_dir = sys.argv[1]
target = sys.argv[2]
alpha = sys.argv[3]

colors = {}
with open(f'{state_dir}/user/generated/material_colors.scss') as f:
    for line in f:
        if ':' in line:
            k, v = line.strip().split(':', 1)
            colors['#' + k.strip() + ' #'] = v.strip().strip(';').strip().lstrip('#')

with open(target) as f:
    content = f.read()
for k, v in colors.items():
    content = content.replace(k, v)
content = content.replace('\$alpha', alpha)
with open(target, 'w') as f:
    f.write(content)
" "$STATE_DIR" "$STATE_DIR/user/generated/terminal/sequences.txt" "$term_alpha"

  for file in /dev/pts/*; do
    if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
      {
      cat "$STATE_DIR"/user/generated/terminal/sequences.txt >"$file"
      } & disown || true
    fi
  done
}

apply_term() {
  apply_anyterm
  apply_kitty
}

# Check if terminal theming is enabled in config
CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
if [ -f "$CONFIG_FILE" ]; then
  enable_terminal=$(jq -r '.appearance.wallpaperTheming.enableTerminal' "$CONFIG_FILE")
  if [ "$enable_terminal" = "true" ]; then
    apply_term
  fi
else
  echo "Config file not found at $CONFIG_FILE. Applying terminal theming by default."
  apply_term
fi

# apply_qt & # Qt theming is already handled by kde-material-colors
