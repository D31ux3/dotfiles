# Estructura del repo

[← Volver al README](../README.md)

```
dotfiles/
├── install.sh              Instalación completa (ver instalacion.md)
├── pkglist.txt             Paquetes oficiales, agrupados por secciones
├── aurlist.txt             Paquetes de AUR
├── vscode-extensions.txt   Extensiones de VS Code
├── todo.txt                Tareas pendientes del entorno
├── Scripts/
│   ├── gpu-drivers.sh      Detecta la GPU e instala sus drivers
│   └── link.sh             Enlaza las configuraciones en ~
├── Configs/
│   ├── .zshrc              → ~/.zshrc
│   ├── .config/            → cada elemento a ~/.config/<nombre>
│   │   ├── hypr/           Hyprland, hypridle, hyprlock y sus scripts
│   │   ├── waybar/
│   │   ├── rofi/
│   │   ├── kitty/
│   │   ├── Code/User/settings.json
│   │   └── ...
│   └── etc/                → copiado a /etc (archivos de sistema)
├── Assets/Pictures/Wallpapers/  → ~/Pictures/Wallpapers
└── docs/                   Esta documentación
```

## Cómo se aplican las configuraciones

`Scripts/link.sh` crea **enlaces simbólicos** desde tu carpeta personal al repo:

- Cada archivo o carpeta de `Configs/` va a `~/` (por ejemplo `Configs/.zshrc` → `~/.zshrc`).
- Cada elemento de `Configs/.config/` va a `~/.config/` uno por uno, así `~/.config` sigue siendo una carpeta normal para el resto de programas.
- **VS Code** es una excepción: solo se enlaza `settings.json`, porque su carpeta contiene caché e historial que no deben ir al repo.

Como son enlaces, **editar `~/.config/...` es editar el repo**: los cambios aparecen en `git status` listos para commitear.

Si ya existía un archivo real en el destino, `link.sh` lo mueve a `~/.dotfiles-backup/<fecha>/` antes de enlazar. Se puede ejecutar las veces que haga falta.

### Archivos de sistema (`Configs/etc`)

Los archivos de `Configs/etc/` se **copian** a `/etc` con permisos de root; no se enlazan, porque el sistema los lee antes de que inicies sesión. Por eso, **después de editarlos hay que volver a copiarlos**:

```bash
sudo install -Dm644 ~/dotfiles/Configs/etc/systemd/zram-generator.conf /etc/systemd/zram-generator.conf
```

(o volver a ejecutar `install.sh`). Ahora solo contiene la configuración de zram (swap comprimido en RAM).

## Archivos que no están en el repo

| Archivo | Por qué |
|---|---|
| `~/.gitconfig` | Contiene tu nombre y correo. `install.sh` le añade la configuración de LFS y delta |
| `~/.config/hypr/conf/monitors_local.lua` | Monitores de cada equipo, generado automáticamente (en `.gitignore`) |

## Cómo añadir cosas

- **Un paquete oficial**: añádelo a la sección que corresponda de `pkglist.txt`. Se admiten comentarios con `#`.
- **Un paquete de AUR**: añádelo a `aurlist.txt`.
- **La configuración de un programa**: mueve su carpeta de `~/.config/` a `Configs/.config/` y ejecuta `Scripts/link.sh`, que crea el enlace en su lugar.
- **Un archivo de sistema**: ponlo en `Configs/etc/` con la misma ruta que tendría en `/etc`. `install.sh` lo copia.
- **Una extensión de VS Code**: instálala y actualiza la lista con `code --list-extensions > vscode-extensions.txt`.
