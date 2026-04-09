#!/bin/bash

sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf ./yay
fi

cat pkglist.txt | xargs -n 1 sudo pacman -S --needed --noconfirm
yay -S --needed -noconfirm - < aurlist.txt

cp -r ~/dotfiles/Configs/. ~/

echo "rebootea y seguro se rompe todo un saludo"
