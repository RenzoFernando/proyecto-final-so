# Proyecto Final - Sistemas Operacionales

Herramientas de consola para apoyar tareas básicas de administración en un data center.

## Integrantes

- Renzo Mosquera Daza – A00401681
- Luna Catalina Martínez – A00401964
- Hideki Tamura Hernández – A00348618

## Herramientas

- `bash/`: versión para Linux, WSL y distribuciones basadas en GNU/Linux.
- `powershell/`: versión para Windows.
- `docs/`: documentación del proyecto.

## Funciones principales

1. Usuarios creados y último login.
2. Filesystems/discos conectados con tamaño y espacio libre.
3. Diez archivos más grandes de una ruta indicada.
4. Memoria libre y swap/pagefile en uso.
5. Backup de un directorio a USB con catálogo CSV.

## Ejecución rápida

Bash:

```bash
chmod +x bash/main.sh
./bash/main.sh
```

PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\powershell\Main.ps1
```

## Documentación

- [Manual de usuario](docs/manual_usuario.md)
- [Decisiones técnicas](docs/decisiones_tecnicas.md)
- [Reparto del equipo](docs/reparto_equipo.md)
- [Uso de IA](docs/uso_ia.md)
- [Enunciado del proyecto](docs/proyecto_final.pdf)

## Estructura general

```text
bash/          Herramienta para Linux.
powershell/    Herramienta para Windows.
docs/          Documentación del proyecto.
```
