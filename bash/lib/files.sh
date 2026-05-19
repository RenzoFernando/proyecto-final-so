show_top_ten_files() {
    print_section_title "Diez archivos más grandes"

    read -r -p "Digite el disco, filesystem o directorio a consultar: " input_path

    if [ -z "$input_path" ]; then
        echo "Debe digitar una ruta."
        return 1
    fi

    if [ ! -e "$input_path" ]; then
        echo "La ruta especificada no existe."
        return 1
    fi

    if [ ! -d "$input_path" ]; then
        echo "La ruta especificada no es un directorio o filesystem válido."
        return 1
    fi

    if command -v realpath > /dev/null 2>&1; then
        search_path="$(realpath "$input_path" 2> /dev/null)"
    else
        search_path="$(cd "$input_path" 2> /dev/null && pwd -P)"
    fi

    if [ -z "$search_path" ]; then
        echo "No se pudo resolver la trayectoria completa."
        return 1
    fi

    error_file="$(mktemp)"
    result="$(find "$search_path" -type f -printf '%s\t%p\n' 2> "$error_file" | sort -rn | head -n 10)"

    if [ -z "$result" ]; then
        echo "No se encontraron archivos en la ruta especificada."
        rm -f "$error_file"
        return 0
    fi

    printf "%18s  %s\n" "TamanoBytes" "TrayectoriaCompleta"
    printf "%18s  %s\n" "------------------" "------------------------------"
    printf "%s\n" "$result" | awk -F '\t' '{printf "%18s  %s\n", $1, $2}'

    if [ -s "$error_file" ]; then
        echo
        echo "Algunos archivos o directorios no se pudieron leer por permisos."
    fi

    rm -f "$error_file"
}
