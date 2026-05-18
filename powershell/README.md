# Herramienta PowerShell

## Ejecución

Desde la carpeta `powershell`:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Main.ps1
```

O desde la raíz del repositorio:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\powershell\Main.ps1
```

## Organización

```text
Main.ps1          Punto de entrada.
lib/UI.ps1        Menú, títulos y utilidades visuales.
lib/Users.ps1     Opción 1.
lib/Storage.ps1   Opción 2.
lib/Files.ps1     Opción 3.
lib/Memory.ps1    Opción 4.
lib/Backup.ps1    Opción 5.
```
