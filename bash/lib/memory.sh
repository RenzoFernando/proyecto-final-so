#!/bin/bash

# ==============================================================================
# Archivo: lib/memory.sh
# Propósito:
#   Implementar la opción 4 del proyecto: memoria libre y swap usado.
# Relación con el curso:
#   Usa /proc/meminfo como interfaz de consulta del kernel Linux. AWK se emplea
#   para extraer registros específicos y hacer cálculos de porcentaje.
# ==============================================================================

# get_meminfo_value
# Entrada:
#   $1: nombre del campo de /proc/meminfo sin los dos puntos.
# Salida:
#   Imprime el valor numérico del campo en KB.
# Descripción:
#   Evita repetir varias expresiones awk y mantiene concentrada la lectura de
#   registros de /proc/meminfo.
get_meminfo_value() {
    local field_name="$1"

    awk -v field="$field_name:" '$1 == field {print $2; exit}' /proc/meminfo
}

# show_memory_and_swap
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime memoria libre/disponible y swap usado en bytes y porcentaje.
# Descripción:
#   Usa MemAvailable si el kernel lo reporta, porque representa mejor la memoria
#   que puede usarse sin swap. Si no existe, usa MemFree. El swap usado se calcula
#   como SwapTotal - SwapFree.
show_memory_and_swap() {
    print_section_title "Memoria libre y swap en uso"

    if [ ! -r /proc/meminfo ]; then
        echo "No se pudo leer /proc/meminfo."
        return 1
    fi

    local mem_total_kb=""
    local mem_free_kb=""
    local mem_available_kb=""
    local swap_total_kb=""
    local swap_free_kb=""
    local mem_total_bytes=0
    local mem_free_bytes=0
    local swap_total_bytes=0
    local swap_free_bytes=0
    local swap_used_bytes=0
    local mem_free_percent="0.00"
    local swap_used_percent="0.00"

    mem_total_kb="$(get_meminfo_value "MemTotal")"
    mem_free_kb="$(get_meminfo_value "MemFree")"
    mem_available_kb="$(get_meminfo_value "MemAvailable")"
    swap_total_kb="$(get_meminfo_value "SwapTotal")"
    swap_free_kb="$(get_meminfo_value "SwapFree")"

    if [ -z "$mem_total_kb" ]; then
        echo "No se pudo obtener la información total de memoria."
        return 1
    fi

    if [ -n "$mem_available_kb" ]; then
        mem_free_kb="$mem_available_kb"
    fi

    if [ -z "$mem_free_kb" ]; then
        echo "No se pudo obtener la información de memoria libre."
        return 1
    fi

    if [ -z "$swap_total_kb" ]; then
        swap_total_kb=0
    fi

    if [ -z "$swap_free_kb" ]; then
        swap_free_kb=0
    fi

    mem_total_bytes=$((mem_total_kb * 1024))
    mem_free_bytes=$((mem_free_kb * 1024))
    swap_total_bytes=$((swap_total_kb * 1024))
    swap_free_bytes=$((swap_free_kb * 1024))
    swap_used_bytes=$((swap_total_bytes - swap_free_bytes))

    if [ "$swap_used_bytes" -lt 0 ]; then
        swap_used_bytes=0
    fi

    if [ "$mem_total_bytes" -gt 0 ]; then
        mem_free_percent="$(awk -v free="$mem_free_bytes" -v total="$mem_total_bytes" 'BEGIN { printf "%.2f", (free * 100) / total }')"
    fi

    if [ "$swap_total_bytes" -gt 0 ]; then
        swap_used_percent="$(awk -v used="$swap_used_bytes" -v total="$swap_total_bytes" 'BEGIN { printf "%.2f", (used * 100) / total }')"
    fi

    printf "%-30s %20s %15s\n" "Recurso" "Bytes" "Porcentaje"
    printf "%-30s %20s %15s\n" "------------------------------" "--------------------" "---------------"
    printf "%-30s %20s %14s%%\n" "Memoria libre" "$mem_free_bytes" "$mem_free_percent"
    printf "%-30s %20s %14s%%\n" "Swap usado" "$swap_used_bytes" "$swap_used_percent"
}
