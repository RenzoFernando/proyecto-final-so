#!/bin/bash

# Realiza una copia de seguridad de un directorio hacia una memoria USB.
# Además crea un catálogo CSV con ruta relativa y fecha de última modificación.

escape_csv_field() {
    printf '%s' "$1" | sed 's/"/""/g'
}

resolve_directory_path() {
    local directory_path="$1"

    if command -v realpath > /dev/null 2>&1; then
        realpath "$directory_path" 2> /dev/null
    else
        cd "$directory_path" 2> /dev/null && pwd -P
    fi
}

get_mount_source_for_path() {
    local directory_path="$1"

    if command -v findmnt > /dev/null 2>&1; then
        findmnt -T "$directory_path" -no SOURCE 2> /dev/null | head -n 1
        return
    fi

    df -P "$directory_path" 2> /dev/null | awk 'NR == 2 {print $1}'
}

is_usb_destination() {
    local destination_path="$1"
    local mount_source=""
    local parent_device=""

    if ! command -v lsblk > /dev/null 2>&1; then
        return 1
    fi

    mount_source="$(get_mount_source_for_path "$destination_path")"

    case "$mount_source" in
        /dev/*)
            ;;
        *)
            return 1
            ;;
    esac

    if lsblk -no RM,TRAN "$mount_source" 2> /dev/null | awk '{ if ($1 == 1 || $2 == "usb") found = 1 } END { exit found ? 0 : 1 }'; then
        return 0
    fi

    parent_device="$(lsblk -no PKNAME "$mount_source" 2> /dev/null | awk 'NF > 0 {print $1; exit}')"

    if [ -n "$parent_device" ]; then
        if lsblk -no RM,TRAN "/dev/$parent_device" 2> /dev/null | awk '{ if ($1 == 1 || $2 == "usb") found = 1 } END { exit found ? 0 : 1 }'; then
            return 0
        fi
    fi

    return 1
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
    local file_path=""

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

    if [ ! -w "$destination_dir" ] || [ ! -x "$destination_dir" ]; then
        echo "El destino no tiene permisos suficientes."
        return 1
    fi

    source_path="$(resolve_directory_path "$source_dir")"
    destination_path="$(resolve_directory_path "$destination_dir")"

    if [ -z "$source_path" ] || [ -z "$destination_path" ]; then
        echo "No se pudieron resolver las trayectorias completas."
        return 1
    fi

    if [ "$source_path" = "$destination_path" ]; then
        echo "El destino no puede ser el mismo directorio origen."
        return 1
    fi

    case "$destination_path/" in
        "$source_path/"*)
            echo "El destino no puede estar dentro del directorio origen."
            return 1
            ;;
    esac

    if ! is_usb_destination "$destination_path"; then
        echo "El destino debe corresponder a una memoria USB o unidad removible montada."
        return 1
    fi

    source_name="$(basename "$source_path")"

    if [ -z "$source_name" ] || [ "$source_name" = "/" ]; then
        source_name="directorio"
    fi

    timestamp="$(date +%Y%m%d_%H%M%S)"
    backup_dir="$destination_path/backup_${source_name}_${timestamp}"
    catalog_file="$backup_dir/catalogo_backup.csv"

    if ! mkdir "$backup_dir"; then
        echo "No se pudo crear el directorio de backup."
        return 1
    fi

    if ! cp -a "$source_path"/. "$backup_dir"/ 2> /dev/null; then
        echo "No se pudo completar la copia de seguridad."
        rm -rf "$backup_dir"
        return 1
    fi

    if ! printf '"Ruta","UltimaModificacion"\n' > "$catalog_file"; then
        echo "No se pudo crear el catálogo del backup."
        rm -rf "$backup_dir"
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
    done < <(find "$backup_dir" -type f -print0 2> /dev/null | LC_ALL=C sort -z)

    echo "Backup finalizado correctamente."
    echo "Directorio de backup: $backup_dir"
    echo "Catálogo: $catalog_file"
}
