# Herramienta Bash

Herramienta de administración para Linux, WSL y distribuciones GNU/Linux.

## Requisitos

- Bash.
- Comandos: `awk`, `cat`, `cp`, `date`, `df`, `find`, `grep`, `head`, `mkdir`, `mktemp`, `rm`, `sed`, `sort`, `stat`.
- Para validar USB/removible en Linux nativo: `findmnt` y `lsblk`.
- En WSL, las unidades de Windows suelen montarse como `/mnt/c`, `/mnt/d`, `/mnt/e`.

## Ejecución

Desde la raíz:

```bash
chmod +x bash/main.sh
./bash/main.sh
```

Desde la carpeta `bash`:

```bash
chmod +x main.sh
./main.sh
```

## Opciones

1. Usuarios creados y último login.
2. Filesystems/discos conectados.
3. Diez archivos más grandes.
4. Memoria libre y swap en uso.
5. Backup de directorio a USB con catálogo.

## Estructura

```text
main.sh          Punto de entrada.
lib/ui.sh        Menú y utilidades visuales.
lib/users.sh     Usuarios y último login.
lib/storage.sh   Filesystems/discos conectados.
lib/files.sh     Diez archivos más grandes.
lib/memory.sh    Memoria y swap.
lib/backup.sh    Backup y catálogo.
```

## Notas

- Para rutas de Windows en WSL hay que usar formato Linux.
- El backup genera un directorio `backup_nombre_YYYYMMDD_HHMMSS`.
- El catálogo generado se llama `catalogo_backup.csv`.
