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

# Everything in Configs/ (except .config and etc) goes directly to ~/  (e.g. .zshrc)
# Configs/etc holds system files: install.sh copies them to /etc as root, they are not linked
for src in "$DOTFILES"/Configs/.[!.]* "$DOTFILES"/Configs/*; do
    [ -e "$src" ] || continue
    [ "$(basename "$src")" = ".config" ] && continue
    [ "$(basename "$src")" = "etc" ] && continue
    link "$src" "$HOME/$(basename "$src")"
done

# Each directory/file inside Configs/.config is linked individually,
# so ~/.config stays a regular directory for other programs
for src in "$DOTFILES"/Configs/.config/.[!.]* "$DOTFILES"/Configs/.config/*; do
    [ -e "$src" ] || continue
    # VS Code keeps cache, history and workspace data in ~/.config/Code: only its settings are linked (below)
    [ "$(basename "$src")" = "Code" ] && continue
    link "$src" "$HOME/.config/$(basename "$src")"
done

# VS Code settings (extensions are installed by install.sh from vscode-extensions.txt)
link "$DOTFILES/Configs/.config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"

# Each folder in Assets/Pictures goes to ~/Pictures/<name>: Wallpapers (set when Hyprland starts,
# see ~/.config/hypr/scripts/wallpaper.sh), pfp... Linked one by one so ~/Pictures stays a regular directory
for src in "$DOTFILES"/Assets/Pictures/*; do
    [ -e "$src" ] || continue
    link "$src" "$HOME/Pictures/$(basename "$src")"
done

# Fonts that are not packaged (put them in Assets/Fonts).
# Linked one by one so ~/.local/share/fonts stays a regular directory
for src in "$DOTFILES"/Assets/Fonts/*; do
    [ -e "$src" ] || continue
    link "$src" "$HOME/.local/share/fonts/$(basename "$src")"
done
command -v fc-cache >/dev/null && fc-cache -f "$HOME/.local/share/fonts" >/dev/null
