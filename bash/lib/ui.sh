#!/bin/bash

# Funciones de presentación usadas por todos los módulos de la aplicación.

show_main_menu() {
    if command -v clear > /dev/null 2>&1 && [ -n "$TERM" ]; then
        clear
    fi

    echo "=============================================="
    echo " Herramienta Bash - Administración Data Center"
    echo "=============================================="
    echo "1. Usuarios creados y último login"
    echo "2. Filesystems/discos conectados"
    echo "3. Diez archivos más grandes"
    echo "4. Memoria libre y swap en uso"
    echo "5. Backup de directorio a USB con catálogo"
    echo "0. Salir"
    echo "=============================================="
}

pause_screen() {
    echo
    read -r -p "Presione ENTER para continuar..." _
}

print_section_title() {
    echo
    echo "----------------------------------------------"
    echo "$1"
    echo "----------------------------------------------"
}
