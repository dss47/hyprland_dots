function update --wraps='sudo pacman -Syu && yay -Syu' --description 'alias update=sudo pacman -Syu && yay -Syu'
    sudo pacman -Syu && yay -Syu $argv
end
