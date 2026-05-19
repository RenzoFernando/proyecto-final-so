show_filesystems() {
    print_section_title "Filesystems/discos conectados"

    if ! command -v df > /dev/null 2>&1; then
        echo "No se encontró el comando df para consultar filesystems."
        return 1
    fi

    df -B1 -P 2> /dev/null | awk '
        NR == 1 {
            printf "%-30s %-35s %18s %18s\n", "Filesystem", "PuntoMontaje", "TamanoBytes", "LibreBytes"
            printf "%-30s %-35s %18s %18s\n", "------------------------------", "-----------------------------------", "------------------", "------------------"
            next
        }
        NR > 1 {
            mount_point = $6
            for (i = 7; i <= NF; i++) {
                mount_point = mount_point " " $i
            }
            printf "%-30s %-35s %18s %18s\n", $1, mount_point, $2, $4
        }
    '
}
