#!/bin/bash

#====== DIRECTORIES ======
CONFIG_BACKUPS_DIR="$BASE_DIR/config_backups/"
SERVICE_FILES_DIR="$BASE_DIR/service_files/"
IPTABLES_FILES_DIR="$BASE_DIR/iptables_files/"
SYS_FILE="$IPTABLES_FILES_DIR/sys_firewall_rules.sh"
SERVICE_FILE="$SERVICE_FILES_DIR/iptables-rules.service"
FILE_SCRIPT="$BASE_DIR/file-utils.sh"
UTILS_SCRIPT="$BASE_DIR/utils.sh"
IPTABLES_SCRIPT="$BASE_DIR/iptables-utils.sh"
SERVICE_SCRIPT="$BASE_DIR/service-utils.sh"

##User Save Directories
USER_SERVICE_SAVE="${HOME}/.config/systemd/user/"
##System Save Directories
SYSTEM_SERVICE_SAVE="/etc/systemd/system/"
##Common Save Directories
CONFIG_SAVE="$HOME/.local/share/iptables-creator/config.txt"

#====== FILE CLEANING ======
reset_sys_file()
{
    if [ -e "$SYS_FILE" ]; then
        truncate -s 0 "$SYS_FILE"
    else
        mkdir -p "$IPTABLES_FILES_DIR" && touch "$SYS_FILE"
    fi
    printf "#!/bin/bash\n" > "$SYS_FILE"
}

reset_service_file()
{
    if [ -e "$SERVICE_FILE" ]; then
        truncate -s "$SERVICE_FILE"
    else
        mkdir -p "$SERVICE_FILES_DIR" && touch "$SERVICE_FILE"
    fi
}

#====== FILE READING ======
read_file_coincidencies()
{
    local file="$1" prefix="$2" sufix="$3" grep_result multiple_coincidences=$4 line="line number"

    [[ ! -e "$file" ]] && {
        print_error "File $file to read from not found" 2 >&2
        return 1
    }

    if [[ -z "$sufix" ]]; then
        grep_result="$(grep "${prefix}.*" "$file")"
    elif [[ -z "$prefix" ]]; then
        grep_result="$(grep ".*${sufix}" "$file")"
    else
        grep_result="$(grep "${prefix}.*${sufix}" "$file")"
    fi

    if [[ "$multiple_coincidences" -ne 0 && "$(echo "$grep_result" | wc -l)" -gt 1 ]]; then
        print_warning "You have more than 1 coincidence, please select 1 of them by writing the line number" 1 

        local coincidences_number
        coincidences_number="$(echo "$grep_result" | wc -l)"
        
        while ! check_only_numbers "$line" || [ "$line" -gt "$coincidences_number" ] ; do
            printf "%s\n" "$grep_result" >&2
            read -r -p "Line Selection: " line
        done

        grep_result="$(echo "$grep_result" | sed -n "${line}p")"
    fi

    printf "%s" "$grep_result"
}

#====== FILE PRINT ======
print_file()
{
    local file="$1"

    if [ ! -f "$file" ]; then
        print_error "This file doesn't exists, imposible to print" 4
    else
        printf "%s\n" "$(cat "$file")"
        enter_to_continue
    fi
}