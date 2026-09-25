#!/bin/bash
# Crea symlinks desde $HOME hacia los archivos del repo.
# Así, editar ~/.config/<algo> edita directamente el repo (y viceversa).
# Si ya existe un archivo/carpeta real en el destino, se mueve a ~/.dotfiles-backup/<fecha>/

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
    local src="$1" dest="$2"

    # Ya apunta al lugar correcto: nada que hacer
    if [ "$(readlink "$dest")" = "$src" ]; then
        echo "ok      $dest"
        return
    fi

    # Hay algo en el destino (archivo, carpeta o symlink viejo): respaldarlo
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP/$(dirname "${dest#$HOME/}")"
        mv "$dest" "$BACKUP/${dest#$HOME/}"
        echo "backup  $dest -> $BACKUP/${dest#$HOME/}"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "link    $dest -> $src"
}

# Todo lo que está en Configs/ (menos .config) va directo a ~/  (ej: .zshrc)
for src in "$DOTFILES"/Configs/.[!.]* "$DOTFILES"/Configs/*; do
    [ -e "$src" ] || continue
    [ "$(basename "$src")" = ".config" ] && continue
    link "$src" "$HOME/$(basename "$src")"
done

# Cada carpeta/archivo dentro de Configs/.config se enlaza por separado,
# así ~/.config sigue siendo una carpeta normal para el resto de programas
for src in "$DOTFILES"/Configs/.config/.[!.]* "$DOTFILES"/Configs/.config/*; do
    [ -e "$src" ] || continue
    link "$src" "$HOME/.config/$(basename "$src")"
done

# Wallpapers (se ponen al iniciar Hyprland, ver ~/.config/hypr/scripts/wallpaper.sh)
link "$DOTFILES/Assets/Pictures/Wallpapers" "$HOME/Pictures/Wallpapers"
