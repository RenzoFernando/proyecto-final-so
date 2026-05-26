#!/bin/bash

# ==============================================================================
# Archivo: lib/storage.sh
# Propósito:
#   Implementar la opción 2 del proyecto: listar filesystems o discos conectados.
# Relación con el curso:
#   Usa comandos del sistema operativo y AWK como filtro de texto. df consulta la
#   información del sistema de archivos y awk formatea los campos requeridos.
# ==============================================================================

# show_filesystems
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime filesystem, punto de montaje, tamaño total en bytes y bytes libres.
# Descripción:
#   Ejecuta df con tamaño en bytes (-B1) y formato portable (-P). Luego usa awk
#   para seleccionar únicamente las columnas relevantes para la rúbrica.
show_filesystems() {
    local df_output=""

    print_section_title "Filesystems/discos conectados"

    if ! command -v df > /dev/null 2>&1; then
        echo "No se encontró el comando df para consultar filesystems."
        return 1
    fi

    if ! df_output="$(df -B1 -P 2> /dev/null)"; then
        echo "No se pudieron consultar los filesystems conectados."
        return 1
    fi

    printf "%s\n" "$df_output" | awk '
        NR == 1 {
            printf "%-30s %-35s %18s %18s\n", "Filesystem", "PuntoMontaje", "TamanoBytes", "LibreBytes"
            printf "%-30s %-35s %18s %18s\n", "------------------------------", "-----------------------------------", "------------------", "------------------"
            next
        }
        NR > 1 {
            mount_point = $6
            for (i = 7; i <= NF; i++) {
                mount_point = mount_point " " $i
            }
            printf "%-30s %-35s %18s %18s\n", $1, mount_point, $2, $4
        }
    '
}
