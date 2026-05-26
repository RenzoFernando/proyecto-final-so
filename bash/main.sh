#!/bin/bash

# ==============================================================================
# Archivo: main.sh
# Propósito:
#   Punto de entrada de la herramienta Bash del proyecto final de Sistemas
#   Operacionales. Este script carga las bibliotecas funcionales, verifica que las
#   funciones requeridas existan y mantiene el ciclo principal del menú.
# Relación con el curso:
#   El archivo sigue el modelo de script de shell interpretado: inicia con shebang,
#   declara variables al comienzo de los bloques relevantes, usa funciones para
#   separar responsabilidades y aplica una instrucción case para selección múltiple.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# import_script
# Entrada:
#   $1: ruta absoluta del script que se desea cargar.
# Salida:
#   No imprime nada si la carga es correcta. Termina la aplicación si el archivo no
#   existe o no puede leerse.
# Descripción:
#   Centraliza la carga de módulos con source. Antes de importar, valida existencia
#   y permiso de lectura para evitar errores difíciles de rastrear durante el menú.
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

# require_function
# Entrada:
#   $1: nombre de la función que debe estar disponible.
# Salida:
#   No imprime nada si la función existe. Termina la aplicación si no fue cargada.
# Descripción:
#   Verifica la integridad mínima de los módulos importados. Si un archivo existe,
#   pero no define la función esperada, la aplicación falla antes de mostrar el menú.
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

# main
# Entrada:
#   Lee por teclado la opción seleccionada por el usuario.
# Salida:
#   Ejecuta la función correspondiente a cada opción del proyecto.
# Descripción:
#   Mantiene el menú en un ciclo while. La instrucción case concentra la selección
#   múltiple y permite salir únicamente cuando el usuario selecciona la opción 0.
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
