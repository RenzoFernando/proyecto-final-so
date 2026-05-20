#!/bin/bash

escape_csv_field() {
    printf '%s' "$1" | sed 's/"/""/g'
}

run_backup() {
    print_section_title "Backup de directorio a USB con catálogo"

    local source_dir=""
    local destination_dir=""
    local source_path=""
    local destination_path=""
    local source_name=""
    local timestamp=""
    local backup_dir=""
    local catalog_file=""
    local relative_path=""
    local last_modified=""
    local escaped_path=""
    local escaped_modified=""

    read -r -p "Digite el directorio origen: " source_dir
    read -r -p "Digite el directorio destino en la USB: " destination_dir

    if [ -z "$source_dir" ]; then
        echo "Debe digitar el directorio origen."
        return 1
    fi

    if [ -z "$destination_dir" ]; then
        echo "Debe digitar el directorio destino."
        return 1
    fi

    if [ ! -d "$source_dir" ]; then
        echo "El directorio origen no existe o no es un directorio."
        return 1
    fi

    if [ ! -r "$source_dir" ] || [ ! -x "$source_dir" ]; then
        echo "No hay permisos suficientes para leer el directorio origen."
        return 1
    fi

    if [ ! -d "$destination_dir" ]; then
        echo "El destino no existe o no es un directorio."
        return 1
    fi

    if [ ! -w "$destination_dir" ]; then
        echo "El destino no tiene permisos de escritura."
        return 1
    fi

    if command -v realpath > /dev/null 2>&1; then
        source_path="$(realpath "$source_dir" 2> /dev/null)"
        destination_path="$(realpath "$destination_dir" 2> /dev/null)"
    else
        source_path="$(cd "$source_dir" 2> /dev/null && pwd -P)"
        destination_path="$(cd "$destination_dir" 2> /dev/null && pwd -P)"
    fi

    if [ -z "$source_path" ] || [ -z "$destination_path" ]; then
        echo "No se pudieron resolver las trayectorias completas."
        return 1
    fi

    source_name="$(basename "$source_path")"

    if [ -z "$source_name" ] || [ "$source_name" = "/" ]; then
        source_name="directorio"
    fi

    timestamp="$(date +%Y%m%d_%H%M%S)"
    backup_dir="$destination_path/backup_${source_name}_${timestamp}"
    catalog_file="$backup_dir/catalogo_backup.csv"

    if ! mkdir -p "$backup_dir"; then
        echo "No se pudo crear el directorio de backup."
        return 1
    fi

    if ! cp -a "$source_path"/. "$backup_dir"/ 2> /dev/null; then
        echo "No se pudo completar la copia de seguridad."
        return 1
    fi

    if ! printf '"Ruta","UltimaModificacion"\n' > "$catalog_file"; then
        echo "No se pudo crear el catálogo del backup."
        return 1
    fi

    while IFS= read -r -d '' file_path; do
        relative_path="${file_path#"$backup_dir"/}"

        if [ "$relative_path" != "catalogo_backup.csv" ]; then
            if last_modified="$(stat -c '%y' "$file_path" 2> /dev/null)"; then
                escaped_path="$(escape_csv_field "$relative_path")"
                escaped_modified="$(escape_csv_field "$last_modified")"
                printf '"%s","%s"\n' "$escaped_path" "$escaped_modified" >> "$catalog_file"
            fi
        fi
    done < <(find "$backup_dir" -type f -print0 2> /dev/null)

    echo "Backup finalizado correctamente."
    echo "Directorio de backup: $backup_dir"
    echo "Catálogo: $catalog_file"
}
