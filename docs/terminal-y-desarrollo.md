# Terminal y desarrollo

[← Volver al README](../README.md)

## Shell: zsh

La shell es **zsh** con Oh My Zsh (plugin `git`) y el prompt **starship**. Configuración en `Configs/.zshrc`.

- **Autosugerencias**: mientras escribes aparece en gris el resto del comando, sacado del historial. `→` lo acepta y `Ctrl + →` acepta una palabra.
- **Resaltado de sintaxis**: el comando se colorea al escribirlo y sale en rojo si no existe.
- **Editor**: `EDITOR` y `VISUAL` son `code --wait` en la sesión gráfica, así que los commits de Git, `sudoedit` o `Ctrl + X, Ctrl + E` abren VS Code y esperan a que cierres la pestaña. Sin sesión gráfica (TTY, SSH) se usa nano.

### Alias y funciones

| Comando | Qué hace |
|---|---|
| `ls` | Lista con iconos y las carpetas primero (eza) |
| `la` | Lista detallada con ocultos y estado de Git |
| `ll` | Lista detallada con estado de Git |
| `lt` | Árbol de dos niveles |
| `cat` | `bat`: muestra archivos con resaltado de sintaxis |
| `ff` | fastfetch (información del sistema) |
| `gacp "mensaje"` | `git add .` + commit con ese mensaje + push |
| `orphans` | Desinstala los paquetes huérfanos (dependencias que ya nadie usa) |
| `dots` | Ir a `~/dotfiles` |
| `reload` | Recargar `.zshrc` |

### Herramientas de terminal

| Herramienta | Uso |
|---|---|
| `fzf` | Buscador interactivo: `Ctrl + R` historial, `Ctrl + T` archivos (con vista previa), `Alt + C` carpetas |
| `z <parte de la ruta>` | Salta a la carpeta más usada que coincida (zoxide). `zi` la elige con fzf |
| `rg <texto>` | Buscar texto en archivos (ripgrep), respeta `.gitignore` |
| `fd <nombre>` | Buscar archivos por nombre |
| `bat <archivo>` | Ver un archivo con colores y números de línea |
| `jq` | Leer y filtrar JSON |
| `tldr <comando>` | Ejemplos prácticos de un comando (tealdeer) |
| `btop`, `htop` | Monitores de procesos y recursos |
| `lazygit` | Interfaz de Git en la terminal |

## Git

- **delta** muestra los diffs con resaltado de sintaxis y los cambios por palabra. En un diff largo, `n` / `N` saltan entre archivos.
- Los conflictos usan el estilo `zdiff3`, que muestra también el código original.
- **Git LFS** está activado para los archivos grandes (texturas, modelos, audio) en los repos que lo configuran en `.gitattributes`.
- `~/.gitconfig` no está en el repo (tiene tu identidad); `install.sh` le añade lo anterior.
- **GitHub CLI** (`gh`) para PRs e issues desde la terminal.

## Lenguajes: mise

**mise** instala y cambia la versión de cada lenguaje por proyecto (Node, Python, Rust, Go...). En la carpeta de un proyecto:

```bash
mise use node@22      # instala Node 22 y lo fija en mise.toml
mise use python@3.13
```

Al entrar en la carpeta se activan esas versiones solas. mise también carga variables de entorno de la sección `[env]` de `mise.toml`.

Además vienen instalados:

- **C/C++**: clang, lldb (depurador), cmake, ninja, meson, pkgconf, valgrind.
- **.NET**: `dotnet-sdk` (para Godot C# o Unity).

## Docker

Docker con `compose` y `buildx`. No arranca con el sistema: se inicia solo la primera vez que ejecutas un comando `docker`. Tu usuario está en el grupo `docker`, así que no necesitas `sudo`.

## VS Code

- Se ejecuta en **Wayland nativo** (no se ve borroso con escalado) y guarda los tokens en **gnome-keyring**. Esto lo configuran `ELECTRON_OZONE_PLATFORM_HINT` en `hypr/conf/env.lua` y `Configs/.config/code-flags.conf`.
- **Ajustes**: `Configs/.config/Code/User/settings.json` está enlazado, así que lo que cambias en VS Code se guarda en el repo.
- **Extensiones**: `install.sh` instala las de `vscode-extensions.txt`. Si añades o quitas alguna, actualiza la lista:
  ```bash
  code --list-extensions > ~/dotfiles/vscode-extensions.txt
  ```

## Kitty (terminal)

Tema Tokyo Night, fondo semitransparente y fuente CaskaydiaCove Nerd Font. Hay más temas en `Configs/.config/kitty/themes/`; se cambia la línea `include` de `kitty.conf`.
