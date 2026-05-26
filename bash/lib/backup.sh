#!/bin/bash

# ==============================================================================
# Archivo: lib/backup.sh
# Propósito:
#   Implementar la opción 5 del proyecto: backup de un directorio a una memoria USB
#   con generación de catálogo.
# Relación con el curso:
#   Usa manejo de archivos y directorios, validaciones con test, variables locales,
#   sustitución de comandos, pipeline y procesamiento de texto con sed/find/stat.
# ==============================================================================

# escape_csv_field
# Entrada:
#   $1: texto que será escrito como campo CSV.
# Salida:
#   Imprime el texto con comillas dobles escapadas según formato CSV.
# Descripción:
#   El catálogo se escribe entre comillas. Si una ruta contiene comillas, deben
#   duplicarse para no romper la estructura del archivo CSV.
escape_csv_field() {
    printf '%s' "$1" | sed 's/"/""/g'
}

# resolve_directory_path
# Entrada:
#   $1: directorio a resolver.
# Salida:
#   Imprime la ruta absoluta del directorio.
# Descripción:
#   Normaliza origen y destino antes de compararlos. Esto evita aceptar como rutas
#   distintas dos formas equivalentes de escribir el mismo directorio.
resolve_directory_path() {
    local directory_path="$1"

    if command -v realpath > /dev/null 2>&1; then
        realpath "$directory_path" 2> /dev/null
    else
        cd "$directory_path" 2> /dev/null && pwd -P
    fi
}

# get_mount_source_for_path
# Entrada:
#   $1: ruta dentro del filesystem montado.
# Salida:
#   Imprime el dispositivo origen del punto de montaje.
# Descripción:
#   findmnt identifica el dispositivo que soporta una ruta. Si no existe, df funciona
#   como alternativa para obtener la primera columna del montaje.
get_mount_source_for_path() {
    local directory_path="$1"

    if command -v findmnt > /dev/null 2>&1; then
        findmnt -T "$directory_path" -no SOURCE 2> /dev/null | head -n 1
        return
    fi

    df -P "$directory_path" 2> /dev/null | awk 'NR == 2 {print $1}'
}

# is_usb_destination
# Entrada:
#   $1: ruta destino resuelta.
# Salida:
#   Status 0 si el destino corresponde a USB/removible; status 1 en caso contrario.
# Descripción:
#   Verifica la rúbrica del backup a USB. Primero obtiene el dispositivo montado y
#   luego consulta con lsblk si el dispositivo o su padre son removibles o USB.
is_usb_destination() {
    local destination_path="$1"
    local mount_source=""
    local mount_fstype=""
    local parent_device=""
    local normalized_destination=""
    local drive_letter=""
    local windows_drive_type=""

    if command -v findmnt > /dev/null 2>&1; then
        mount_fstype="$(findmnt -T "$destination_path" -no FSTYPE 2> /dev/null | head -n 1)"
    else
        mount_fstype="$(df -T "$destination_path" 2> /dev/null | awk 'NR == 2 {print $2}')"
    fi

    mount_source="$(get_mount_source_for_path "$destination_path")"
    normalized_destination="${destination_path%/}"

    case "$normalized_destination" in
        /mnt/[A-Za-z]|/mnt/[A-Za-z]/*)
            drive_letter="$(printf '%s' "$normalized_destination" | awk -F/ '{print toupper($3)}')"
            ;;
    esac

    if [ -z "$drive_letter" ]; then
        case "$mount_source" in
            [A-Za-z]:\\|[A-Za-z]:/|[A-Za-z]:\\*|[A-Za-z]:/*)
                drive_letter="$(printf '%s' "$mount_source" | cut -c 1 | tr '[:lower:]' '[:upper:]')"
                ;;
        esac
    fi

    if [ -n "$drive_letter" ] && { [ "$mount_fstype" = "drvfs" ] || [ "$mount_fstype" = "9p" ] || printf '%s' "$mount_source" | grep -Eq '^[A-Za-z]:[\\/]'; }; then
        if command -v powershell.exe > /dev/null 2>&1; then
            windows_drive_type="$(powershell.exe -NoProfile -Command "(Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='$drive_letter:'\").DriveType" 2> /dev/null | tr -d '\r' | awk 'NF > 0 {print $1; exit}')"

            if [ "$windows_drive_type" = "2" ]; then
                return 0
            fi

            return 1
        fi

        case "$drive_letter" in
            C)
                return 1
                ;;
            *)
                return 0
                ;;
        esac
    fi

    if ! command -v lsblk > /dev/null 2>&1; then
        return 1
    fi

    case "$mount_source" in
        /dev/*)
            ;;
        *)
            case "$destination_path" in
                /media/*|/run/media/*)
                    return 0
                    ;;
            esac

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

    case "$destination_path" in
        /media/*|/run/media/*)
            return 0
            ;;
    esac

    return 1
}

# write_backup_catalog
# Entrada:
#   $1: directorio de backup ya creado.
#   $2: ruta del archivo CSV que será generado.
# Salida:
#   Crea el catálogo con ruta relativa y fecha de última modificación.
# Descripción:
#   Recorre los archivos copiados, excluye el propio catálogo y escribe registros
#   CSV ordenados. Se usan nombres terminados en nulo para soportar espacios.
write_backup_catalog() {
    local backup_dir="$1"
    local catalog_file="$2"
    local relative_path=""
    local last_modified=""
    local escaped_path=""
    local escaped_modified=""
    local file_path=""

    if ! printf '"Ruta","UltimaModificacion"\n' > "$catalog_file"; then
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

    return 0
}

# run_backup
# Entrada:
#   Lee por teclado directorio origen y directorio destino en USB.
# Salida:
#   Copia archivos y muestra la ruta del backup y del catálogo.
# Descripción:
#   Coordina toda la opción 5: valida entradas, permisos, rutas equivalentes, destino
#   USB, crea directorio con timestamp, copia con cp -a y genera catálogo CSV.
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

    if ! write_backup_catalog "$backup_dir" "$catalog_file"; then
        echo "No se pudo crear el catálogo del backup."
        rm -rf "$backup_dir"
        return 1
    fi

    echo "Backup finalizado correctamente."
    echo "Directorio de backup: $backup_dir"
    echo "Catálogo: $catalog_file"
}
