# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != "linux"
        alias ls 'eza --icons'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
end

# Created by `pipx` on 2026-05-14 22:22:23
set PATH $PATH /home/saad/.local/bin
function arduino-ide; /usr/bin/arduino-ide --enable-features=UseOzonePlatform --ozone-platform=x11 $argv; end

function odoo-upgrade
    sudo -u odoo odoo -d odoo -u $argv[1] --addons-path=/usr/share/odoo/venv/lib/python3.14/site-packages/odoo/addons,/var/lib/odoo/.local/share/Odoo/addons/18.0,/opt/odoo-addons --stop-after-init
end

alias voice-agent '/usr/local/bin/voice-agent'
