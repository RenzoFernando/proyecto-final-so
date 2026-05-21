#!/bin/bash

get_created_users() {
    if command -v getent > /dev/null 2>&1; then
        getent passwd | awk -F: '{print $1}' | sort
    else
        awk -F: '{print $1}' /etc/passwd | sort
    fi
}

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
