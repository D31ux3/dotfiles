#!/bin/bash

echo "
    ____                      ___              __       __    __          
   /  _/  __  __________     /   |  __________/ /_     / /_  / /__      __
   / /   / / / / ___/ _ \   / /| | / ___/ ___/ __ \   / __ \/ __/ | /| / /
 _/ /   / /_/ (__  )  __/  / ___ |/ /  / /__/ / / /  / /_/ / /_ | |/ |/ / 
/___/   \__,_/____/\___/  /_/  |_/_/   \___/_/ /_/  /_.___/\__/ |__/|__/  
                                                                          
"

# Update system
sudo pacman -Syu --noconfirm

# Install YAY (AUR helper)
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf ./yay
fi

# Install official packages 
while read pkg; do
    sudo pacman -S --needed --noconfirm "$pkg" || echo "Failed to install: $pkg"
done < pkglist.txt

# Install AUR packages
while read pkg; do
    yay -S --needed --noconfirm "$pkg" || echo "Failed to install: $pkg"
done < aurlist.txt

# Install OHMYZSH (zsh is installed with official packages)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Copy configuration files
cp -r ~/dotfiles/Configs/. ~/


# Copy Wallpapers
cp -r ~/dotfiles/Assets/Pictures/. ~/Pictures

# Enable GUI login
sudo systemctl enable gdm

echo "rebootea y seguro se rompe todo un saludo"
