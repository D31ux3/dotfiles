#!/bin/bash

sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf ./yay
fi

while read pkg; do
    sudo pacman -S --needed --noconfirm "$pkg" || echo "Failed to install: $pkg"
done < pkglist.txt

while read pkg; do
    yay -S --needed --noconfirm "$pkg" || echo "Failed to install: $pkg"
done < aurlist.txt

cp -r ~/dotfiles/Configs/. ~/

sudo systemctl enable sddm

echo "rebootea y seguro se rompe todo un saludo"
