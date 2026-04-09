#!/bin/bash

sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf ./yay
fi

sudo pacman -S --needed --noconfirm - < pkglist.txt
yay -S --needed -noconfirm - < aurlist.txt

cp -r ~/dotfiles/* ~/

echo "rebootea y seguro se rompe todo un saludo"