# Manual de usuario

## Objetivo

Explicar cómo ejecutar y usar las dos herramientas del proyecto:

- Herramienta Bash.
- Herramienta PowerShell.

## Ejecución en Bash

Desde la raíz del repositorio:

```bash
chmod +x bash/main.sh
./bash/main.sh
```

## Ejecución en PowerShell

Desde la raíz del repositorio:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\powershell\Main.ps1
```

## Menú principal

Ambas herramientas deben mostrar las mismas opciones:

1. Usuarios y último login.
2. Discos/filesystems.
3. Diez archivos más grandes.
4. Memoria libre y swap/pagefile.
5. Backup a USB con catálogo.
0. Salir.
