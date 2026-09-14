function installp --wraps='sudo pacman -S' --description 'alias installp=sudo pacman -S'
    sudo pacman -S $argv
end
