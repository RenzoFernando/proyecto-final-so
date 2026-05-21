show_top_ten_files() {
    local input_path=""
    local search_path=""
    local error_file=""
    local result_file=""

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

    if [ ! -r "$input_path" ] || [ ! -x "$input_path" ]; then
        echo "No hay permisos suficientes para leer la ruta especificada."
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

    if [ -z "$error_file" ]; then
        echo "No se pudo crear un archivo temporal para errores."
        return 1
    fi

    result_file="$(mktemp)"

    if [ -z "$result_file" ]; then
        echo "No se pudo crear un archivo temporal para resultados."
        rm -f "$error_file"
        return 1
    fi

    find "$search_path" -type f -printf '%s\t%p\0' 2> "$error_file" | LC_ALL=C sort -z -rn | head -z -n 10 > "$result_file"

    if [ ! -s "$result_file" ]; then
        echo "No se encontraron archivos en la ruta especificada."
        rm -f "$error_file" "$result_file"
        return 0
    fi

    printf "%18s  %s\n" "TamanoBytes" "TrayectoriaCompleta"
    printf "%18s  %s\n" "------------------" "------------------------------"
    awk -v RS='\0' -F '\t' '
        NF >= 2 {
            path = $2
            for (i = 3; i <= NF; i++) {
                path = path FS $i
            }
            printf "%18s  %s\n", $1, path
        }
    ' "$result_file"

    if [ -s "$error_file" ]; then
        echo
        echo "Algunos archivos o directorios no se pudieron leer por permisos."
    fi

    rm -f "$error_file" "$result_file"
}
