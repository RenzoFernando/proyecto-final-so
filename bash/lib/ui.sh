#!/bin/bash

# ==============================================================================
# Archivo: lib/ui.sh
# Propósito:
#   Contener las funciones de interfaz de consola usadas por todos los módulos.
# Relación con el curso:
#   Este archivo agrupa comandos simples de salida estándar. Al separarlos, el menú
#   y las pantallas se mantienen consistentes sin repetir código en cada opción.
# ==============================================================================

# show_main_menu
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime en pantalla las opciones principales de la herramienta.
# Descripción:
#   Limpia la terminal cuando es posible y despliega el menú solicitado por la
#   rúbrica: usuarios, filesystems, archivos grandes, memoria/swap y backup.
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

# pause_screen
# Entrada:
#   Espera ENTER desde teclado.
# Salida:
#   No retorna datos; solo detiene temporalmente el flujo.
# Descripción:
#   Permite revisar la salida de una opción antes de regresar al menú principal.
pause_screen() {
    echo
    read -r -p "Presione ENTER para continuar..." _
}

# print_section_title
# Entrada:
#   $1: texto del título de sección.
# Salida:
#   Imprime un encabezado visual para la opción ejecutada.
# Descripción:
#   Uniforma la presentación de resultados y evita que cada módulo repita líneas
#   decorativas o formato de títulos.
print_section_title() {
    echo
    echo "----------------------------------------------"
    echo "$1"
    echo "----------------------------------------------"
}
