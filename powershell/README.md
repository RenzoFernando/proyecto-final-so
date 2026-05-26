# Herramienta PowerShell

Herramienta de administración para Windows.

## Requisitos

- Windows PowerShell 5.1 o PowerShell 7 en Windows.
- Permisos suficientes para consultar usuarios, discos, memoria y pagefile.
- Para backup: memoria USB o unidad removible conectada y con permisos de escritura.

## Ejecución

Desde la raíz:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\powershell\Main.ps1
```

Desde la carpeta `powershell`:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Main.ps1
```

## Opciones

1. Usuarios creados y último login.
2. Filesystems/discos conectados.
3. Diez archivos más grandes.
4. Memoria libre y swap/pagefile en uso.
5. Backup de directorio a USB con catálogo.

## Estructura

```text
Main.ps1          Punto de entrada.
lib/UI.ps1        Menú y utilidades visuales.
lib/Users.ps1     Usuarios y último login.
lib/Storage.ps1   Filesystems/discos conectados.
lib/Files.ps1     Diez archivos más grandes.
lib/Memory.ps1    Memoria y pagefile.
lib/Backup.ps1    Backup y catálogo.
```

## Notas

- En Windows, el swap se reporta como uso del pagefile.
- El backup genera un directorio `backup_nombre_YYYYMMDD_HHMMSS`.
- El catálogo generado se llama `catalogo_backup.csv`.
