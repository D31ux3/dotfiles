# Atajos de teclado

[← Volver al README](../README.md)

`Super` es la tecla de Windows. Los atajos se definen en `Configs/.config/hypr/conf/keybinds.lua`.

## Aplicaciones

| Atajo | Acción |
|---|---|
| `Super + T` | Terminal (kitty) |
| `Super + B` | Navegador (Brave Origin) |
| `Super + E` | Explorador de archivos (Dolphin) |
| `Super + A` | Lanzador de aplicaciones (rofi). Otra vez lo cierra |
| `Super + V` | Historial del portapapeles |
| `Super + M` | Menú de apagado: bloquear, suspender, cerrar sesión, reiniciar, apagar |
| `Super + L` | Bloquear la pantalla |
| `Super + R` | Reiniciar waybar (si se cuelga o tras editar su configuración) |

## Ventanas

| Atajo | Acción |
|---|---|
| `Super + Q` | Cerrar la ventana |
| `Super + F` | Alternar ventana flotante / en mosaico |
| `Super + Shift + F` | Pantalla completa |
| `Super + J` | Cambiar la división de la ventana (horizontal / vertical) |
| `Super + P` | Fijar una ventana flotante: te sigue a todos los escritorios |
| `Super + C` | Centrar una ventana flotante |
| `Super + ←↑→↓` | Mover el foco |
| `Super + Shift + ←↑→↓` | Mover la ventana |
| `Super + Ctrl + ←↑→↓` | Redimensionar (mantén pulsado para seguir) |
| `Super + clic izquierdo` (arrastrar) | Mover la ventana |
| `Super + clic derecho` (arrastrar) | Redimensionar la ventana |

## Escritorios

| Atajo | Acción |
|---|---|
| `Super + 1…0` | Ir al escritorio 1…10 |
| `Super + Shift + 1…0` | Enviar la ventana a ese escritorio (sin seguirla) |
| `Super + Tab` | Volver al escritorio anterior |
| `Super + rueda del ratón` | Pasar al escritorio siguiente / anterior |
| Tres dedos en horizontal (touchpad) | Cambiar de escritorio |
| `Super + S` | Mostrar u ocultar el *scratchpad* (escritorio flotante oculto) |
| `Super + Shift + S` | Enviar la ventana al scratchpad |

## Capturas de pantalla

| Atajo | Acción |
|---|---|
| `Impr Pant` | Capturar una región al portapapeles |
| `Super + Impr Pant` | Capturar toda la pantalla y abrirla en satty para anotarla |

## Teclas multimedia

Funcionan también con la pantalla bloqueada.

| Tecla | Acción |
|---|---|
| Volumen + / − | Subir / bajar 5 % (máximo 100 %) |
| Silencio | Silenciar la salida de audio |
| Silencio de micrófono | Silenciar el micrófono |
| Brillo + / − | Subir / bajar el brillo |
| Play / Pausa, Siguiente, Anterior | Controlar el reproductor activo (playerctl) |

## Caracteres en español

La distribución es US internacional con AltGr: las teclas normales son las de un teclado americano y los caracteres del español salen con `AltGr` (Alt derecho).

| Atajo | Carácter |
|---|---|
| `AltGr + n` | ñ |
| `AltGr + a` / `e` / `i` / `o` / `u` | á é í ó ú |
| `AltGr + /` | ¿ |
| `AltGr + Shift + 1` | ¡ |
| `AltGr + '` y luego la vocal | Tilde en cualquier vocal (también ü con `AltGr + "`) |

## Terminal (zsh)

| Atajo | Acción |
|---|---|
| `Ctrl + R` | Buscar en el historial de comandos (fzf) |
| `Ctrl + T` | Buscar un archivo e insertar su ruta, con vista previa |
| `Alt + C` | Buscar una carpeta y entrar en ella |
| `→` | Aceptar la sugerencia gris (sacada del historial) |
| `Ctrl + →` | Aceptar solo la siguiente palabra de la sugerencia |
| `Ctrl + X`, `Ctrl + E` | Editar el comando actual en el editor (VS Code) |
