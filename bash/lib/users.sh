#!/bin/bash

# ==============================================================================
# Archivo: lib/users.sh
# Propósito:
#   Implementar la opción 1 del proyecto: usuarios creados y fecha de último login.
# Relación con el curso:
#   Usa archivos y comandos propios de Linux. /etc/passwd funciona como fuente de
#   usuarios locales, mientras lastlog o last consultan registros históricos de
#   ingreso al sistema.
# ==============================================================================

# get_uid_min
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime el UID mínimo configurado para usuarios normales. Si no se puede leer,
#   imprime 1000 como valor por omisión frecuente en Linux.
# Descripción:
#   Evita listar cuentas internas del sistema. Se consulta /etc/login.defs cuando
#   existe porque algunas distribuciones pueden usar un UID mínimo distinto.
get_uid_min() {
    local uid_min=""

    if [ -r /etc/login.defs ]; then
        uid_min="$(awk '$1 == "UID_MIN" {print $2; exit}' /etc/login.defs)"
    fi

    if [ -z "$uid_min" ]; then
        uid_min=1000
    fi

    echo "$uid_min"
}

# get_created_users
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime un usuario por línea.
# Descripción:
#   Lee la base local de usuarios mediante getent o /etc/passwd. Se consideran
#   usuarios interactivos root y usuarios con UID >= UID_MIN cuyo shell no sea
#   nologin ni false.
get_created_users() {
    local uid_min=""

    uid_min="$(get_uid_min)"

    if command -v getent > /dev/null 2>&1; then
        getent passwd
    else
        cat /etc/passwd
    fi | awk -F: -v uid_min="$uid_min" '
        ($3 == 0 || $3 >= uid_min) && $7 !~ /(nologin|false)$/ {
            print $1
        }
    ' | sort
}

# get_last_login_for_user
# Entrada:
#   $1: nombre del usuario.
# Salida:
#   Imprime la fecha de último login o un mensaje de ausencia de registro.
# Descripción:
#   Intenta primero con lastlog, porque está diseñado para consultar el último
#   ingreso por usuario. Si no está disponible, usa last como fuente alternativa.
get_last_login_for_user() {
    local username="$1"
    local login_line=""

    if command -v lastlog > /dev/null 2>&1; then
        login_line="$(lastlog -u "$username" 2> /dev/null | awk 'NR == 2 {$1=""; sub(/^[[:space:]]+/, ""); print}')"

        if [ -z "$login_line" ] || printf "%s" "$login_line" | grep -Eiq "never|nunca|jam[aá]s"; then
            echo "Nunca o sin registro"
            return
        fi

        echo "$login_line"
        return
    fi

    if command -v last > /dev/null 2>&1; then
        login_line="$(last -n 1 "$username" 2> /dev/null | awk 'NF > 0 && $0 !~ /wtmp begins/ {print; exit}')"

        if [ -z "$login_line" ]; then
            echo "Nunca o sin registro"
        else
            echo "$login_line"
        fi

        return
    fi

    echo "No disponible"
}

# show_users_last_login
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime una tabla con usuario y último login.
# Descripción:
#   Coordina la consulta de usuarios y la consulta individual de último ingreso.
#   La salida se mantiene simple para poder sustentarse desde consola.
show_users_last_login() {
    local username=""

    print_section_title "Usuarios creados y último login"

    if [ ! -r /etc/passwd ]; then
        echo "No se pudo leer la lista de usuarios del sistema."
        return 1
    fi

    printf "%-30s %s\n" "Usuario" "UltimoLogin"
    printf "%-30s %s\n" "------------------------------" "------------------------------"

    get_created_users | while IFS= read -r username; do
        if [ -n "$username" ]; then
            printf "%-30s %s\n" "$username" "$(get_last_login_for_user "$username")"
        fi
    done
}
