# Herramienta Bash

Herramienta de administración para Linux orientada a labores básicas de un administrador de data center.

## Requisitos

- Sistema Linux con Bash.
- Comandos estándar: `awk`, `df`, `find`, `sort`, `head`, `stat`, `cp`, `mkdir`, `rm`.
- Para validar backup en USB: `findmnt` y `lsblk`.
- Para consultar último login: `lastlog` o `last`.

## Ejecución

Desde la carpeta `bash`:

```bash
chmod +x main.sh
./main.sh
```

Desde la raíz del repositorio:

```bash
chmod +x bash/main.sh
./bash/main.sh
```

## Opciones del menú

1. Muestra usuarios locales interactivos y la fecha del último login.
2. Muestra filesystems/discos montados, tamaño y espacio libre en bytes.
3. Solicita una ruta y muestra los diez archivos más grandes con trayectoria completa.
4. Muestra memoria libre/disponible y swap usado en bytes y porcentaje.
5. Copia un directorio a una memoria USB y genera `catalogo_backup.csv` con ruta y última modificación.

## Organización

```text
main.sh          Punto de entrada.
lib/ui.sh        Menú, títulos y utilidades visuales.
lib/users.sh     Opción 1.
lib/storage.sh   Opción 2.
lib/files.sh     Opción 3.
lib/memory.sh    Opción 4.
lib/backup.sh    Opción 5.
```
