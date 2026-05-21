#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

import_script() {
    local script_path="$1"

    if [ ! -f "$script_path" ]; then
        echo "No se encontró el archivo requerido: $script_path"
        exit 1
    fi

    if [ ! -r "$script_path" ]; then
        echo "No se puede leer el archivo requerido: $script_path"
        exit 1
    fi

    source "$script_path"
}

require_function() {
    local function_name="$1"

    if ! declare -F "$function_name" > /dev/null; then
        echo "No se cargó la función requerida: $function_name"
        exit 1
    fi
}

import_script "$SCRIPT_DIR/lib/ui.sh"
import_script "$SCRIPT_DIR/lib/users.sh"
import_script "$SCRIPT_DIR/lib/storage.sh"
import_script "$SCRIPT_DIR/lib/files.sh"
import_script "$SCRIPT_DIR/lib/memory.sh"
import_script "$SCRIPT_DIR/lib/backup.sh"

require_function show_main_menu
require_function pause_screen
require_function print_section_title
require_function show_users_last_login
require_function show_filesystems
require_function show_top_ten_files
require_function show_memory_and_swap
require_function run_backup

main() {
    local option=""

    while true; do
        show_main_menu

        if ! read -r -p "Seleccione una opción: " option; then
            echo
            echo "Entrada finalizada."
            exit 1
        fi

        case "$option" in
            1)
                show_users_last_login
                pause_screen
                ;;
            2)
                show_filesystems
                pause_screen
                ;;
            3)
                show_top_ten_files
                pause_screen
                ;;
            4)
                show_memory_and_swap
                pause_screen
                ;;
            5)
                run_backup
                pause_screen
                ;;
            0)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "Opción inválida."
                pause_screen
                ;;
        esac
    done
}

main "$@"
