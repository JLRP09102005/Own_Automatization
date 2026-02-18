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
USER_SERVICE_SAVE="~/.config/systemd/user/"
##System Save Directories
SYSTEM_SERVICE_SAVE="/etc/systemd/user/"

#====== FILE FUNCTIONS ======
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