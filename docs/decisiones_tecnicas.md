# Decisiones técnicas

## Equivalencia entre Bash y PowerShell

El proyecto se implementa como dos aplicaciones equivalentes:

- Bash: orientada a Linux/Unix.
- PowerShell: orientada a Windows/PowerShell.

Las opciones del menú deben tener el mismo comportamiento lógico, aunque internamente usen comandos diferentes.

## Swap en PowerShell

En Windows, el concepto equivalente a swap se documentará como uso del archivo de paginación o memoria virtual, según la fuente usada por la implementación.

## Catálogo del backup

El catálogo debe incluir, como mínimo:

- Ruta o nombre del archivo.
- Fecha de última modificación.

Se recomienda incluir ruta relativa dentro del directorio respaldado para evitar ambigüedad cuando existan archivos con el mismo nombre.
