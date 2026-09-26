#!/bin/bash
# Creates symlinks from $HOME to the files in the repo.
# This way, editing ~/.config/<something> edits the repo directly (and vice versa).
# If a real file/directory already exists at the destination, it is moved to ~/.dotfiles-backup/<date>/

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
    local src="$1" dest="$2"

    # Already points to the right place: nothing to do
    if [ "$(readlink "$dest")" = "$src" ]; then
        echo "ok      $dest"
        return
    fi

    # Something exists at the destination (file, directory or old symlink): back it up
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP/$(dirname "${dest#$HOME/}")"
        mv "$dest" "$BACKUP/${dest#$HOME/}"
        echo "backup  $dest -> $BACKUP/${dest#$HOME/}"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "link    $dest -> $src"
}

# Everything in Configs/ (except .config) goes directly to ~/  (e.g. .zshrc)
for src in "$DOTFILES"/Configs/.[!.]* "$DOTFILES"/Configs/*; do
    [ -e "$src" ] || continue
    [ "$(basename "$src")" = ".config" ] && continue
    link "$src" "$HOME/$(basename "$src")"
done

# Each directory/file inside Configs/.config is linked individually,
# so ~/.config stays a regular directory for other programs
for src in "$DOTFILES"/Configs/.config/.[!.]* "$DOTFILES"/Configs/.config/*; do
    [ -e "$src" ] || continue
    link "$src" "$HOME/.config/$(basename "$src")"
done

# Wallpapers (set when Hyprland starts, see ~/.config/hypr/scripts/wallpaper.sh)
link "$DOTFILES/Assets/Pictures/Wallpapers" "$HOME/Pictures/Wallpapers"
