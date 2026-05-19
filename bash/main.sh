#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

import_script() {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

import_script "$SCRIPT_DIR/lib/ui.sh"
import_script "$SCRIPT_DIR/lib/users.sh"
import_script "$SCRIPT_DIR/lib/storage.sh"
import_script "$SCRIPT_DIR/lib/files.sh"
import_script "$SCRIPT_DIR/lib/memory.sh"
import_script "$SCRIPT_DIR/lib/backup.sh"

if ! declare -F show_filesystems > /dev/null; then
    show_filesystems() {
        print_section_title "Filesystems/discos conectados"
        echo "Funcionalidad pendiente por implementar por Luna."
    }
fi

if ! declare -F show_top_ten_files > /dev/null; then
    show_top_ten_files() {
        print_section_title "Diez archivos más grandes"
        echo "Funcionalidad pendiente por implementar por Luna."
    }
fi

if ! declare -F show_memory_and_swap > /dev/null; then
    show_memory_and_swap() {
        print_section_title "Memoria libre y swap en uso"
        echo "Funcionalidad pendiente por implementar por Hideki."
    }
fi

if ! declare -F run_backup > /dev/null; then
    run_backup() {
        print_section_title "Backup de directorio a USB con catálogo"
        echo "Funcionalidad pendiente por implementar por Hideki."
    }
fi

main() {
    local option=""

    while true; do
        show_main_menu
        read -r -p "Seleccione una opción: " option

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
