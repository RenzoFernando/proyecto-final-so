#!/bin/bash

show_memory_and_swap() {
    print_section_title "Memoria libre y swap en uso"

    if [ ! -r /proc/meminfo ]; then
        echo "No se pudo leer /proc/meminfo."
        return 1
    fi

    local mem_total_kb=""
    local mem_free_kb=""
    local swap_total_kb=""
    local swap_free_kb=""
    local mem_total_bytes=0
    local mem_free_bytes=0
    local swap_total_bytes=0
    local swap_free_bytes=0
    local swap_used_bytes=0
    local mem_free_percent="0.00"
    local swap_used_percent="0.00"

    mem_total_kb="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
    mem_free_kb="$(awk '/^MemFree:/ {print $2}' /proc/meminfo)"
    swap_total_kb="$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)"
    swap_free_kb="$(awk '/^SwapFree:/ {print $2}' /proc/meminfo)"

    if [ -z "$mem_total_kb" ] || [ -z "$mem_free_kb" ]; then
        echo "No se pudo obtener la información de memoria."
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
