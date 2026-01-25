#!/bin/bash

#====== DIRECTORIES ======
SYS_FILE="$BASE_DIR/sys_firewall_rules.sh"

#====== COLORS ======
# Reset
NC="\033[0m"

# Styles
BOLD="\033[1m"
DIM="\033[2m"
UNDERLINE="\033[4m"
BLINK="\033[5m"
REVERSE="\033[7m"

# Text Colors (foreground)
FG_BLACK="\033[30m"
FG_RED="\033[31m"
FG_GREEN="\033[32m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"
FG_MAGENTA="\033[35m"
FG_CYAN="\033[36m"
FG_WHITE="\033[37m"

# Bright Text Colors
FG_BBLACK="\033[90m"
FG_BRED="\033[91m"
FG_BGREEN="\033[92m"
FG_BYELLOW="\033[93m"
FG_BBLUE="\033[94m"
FG_BMAGENTA="\033[95m"
FG_BCYAN="\033[96m"
FG_BWHITE="\033[97m"

# Background Colors
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# Bright Background Colors
BG_BBLACK="\033[100m"
BG_BRED="\033[101m"
BG_BGREEN="\033[102m"
BG_BYELLOW="\033[103m"
BG_BBLUE="\033[104m"
BG_BMAGENTA="\033[105m"
BG_BCYAN="\033[106m"
BG_BWHITE="\033[107m"

#====== CHECK ======
check_only_numbers()
{
    [[ "$1" =~ ^[0-9]+$ ]]
}

#====== INTERFACE ======
print_main_menu()
{
    echo -e "${FG_GREEN}"
    cat << 'MENU'
     _____ _                        _ _ 
    |  ___(_)_ __ _____      ____ _| | |
    | |_  | | '__/ _ \ \ /\ / / _` | | |
    |  _| | | | |  __/\ V  V / (_| | | |
    |_|   |_|_|  \___| \_/\_/ \__,_|_|_|
                                        
    ═══════════════════════════════════════
    [1] → Clear Rules Menu
    [2] → Add Rules Menu
    [3] → Create Service
    [4] → Show Service Status
    [5] → Restore Config
    [0] → Exit
    ═══════════════════════════════════════
MENU
    echo -e "${NC}"
}

print_clean_menu()
{
    echo -e "${FG_GREEN}"
    cat << 'MENU'
     _____ _                        _ _ 
    |  ___(_)_ __ _____      ____ _| | |
    | |_  | | '__/ _ \ \ /\ / / _` | | |
    |  _| | | | |  __/\ V  V / (_| | | |
    |_|   |_|_|  \___| \_/\_/ \__,_|_|_|
                                        
    ═══════════════════════════════════════
    [1] → Add Clean All Rules
    [2] → Add Clean Specific Rule
    [0] → Exit
    ═══════════════════════════════════════
MENU
    echo -e "${NC}"
}

print_rules_menu()
{
    echo -e "${FG_GREEN}"
    cat << 'MENU'
     _____ _                        _ _ 
    |  ___(_)_ __ _____      ____ _| | |
    | |_  | | '__/ _ \ \ /\ / / _` | | |
    |  _| | | | |  __/\ V  V / (_| | | |
    |_|   |_|_|  \___| \_/\_/ \__,_|_|_|
                                        
    ═══════════════════════════════════════
    [1] → Add Default Rules
    [2] → Add Quick Rule
    [3] → Add Specific Rule
    [0] → Exit
    ═══════════════════════════════════════
MENU
    echo -e "${NC}"
}

#Arg1 --> Text / Arg2 --> Wait Time
print_info()
{
    local wait_time="${2:-0}"

    printf "${BOLD}${FG_BLUE}INFO${NC}: %s\n" "$1" >&2
    sleep "$wait_time"
}

#Arg1 --> Text / Arg2 --> Wait Time
print_warning()
{
    local wait_time="${2:-0}"

    printf "${BOLD}${FG_YELLOW}WARNING${NC}: %s\n" "$1" >&2
    sleep "$wait_time"
}

#Arg1 --> Text / Arg2 --> Wait Time
print_error()
{
    local wait_time="${2:-0}"

    printf "${BOLD}${FG_RED}ERROR${NC}: %s\n" "$1" >&2
    sleep "$wait_time"
}

#====== IPTABLES FUNCTIONS ======
##Rule Writer
write_rule()
{
    if [ "$#" -gt 0 ]; then
        printf "$@" >> "$SYS_FILE"
    else
        cat >> "$SYS_FILE"
    fi
}

##Clean Rules
iptables_clean_all_rules()
{
    write_rule << 'CONTENT'
#Clean All Firewall Rules
tables=(filter nat mangle raw security)
for table in "${tables[@]}"; do
    sudo iptables -t "$table" -F
    sudo iptables -t "$table" -X
    sudo iptables -t "$table" -Z

    sudo ip6tables -t "$table" -F
    sudo ip6tables -t "$table" -X
    sudo ip6tables -t "$table" -Z
done
CONTENT
}

##Default no permisssive rules
iptables_default_rules()
{
    write_rule << 'CONTENT'
#Default rules
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD DROP

sudo ip6tables -P INPUT DROP
sudo ip6tables -P OUTPUT DROP
sudo ip6tables -P FORWARD DROP

sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
CONTENT
}

##Firewall rules assistant
iptables_rule_wizzard()
{
    local table action chain target protocol port source dest interface_in interface_out
    local modules=""
    local rule=""

    echo ""
    printf "${FG_CYAN}=== Firewall Rules Assistant ===${NC}"
    echo ""

    #Select table
    read -r -p "Select Table (filter/nat/mangle/raw/security) [filter]: " table
    table="${table:-filter}"

    #Select action
    read -r -p "Select Action (A=add, I=insert, D=delete) [A]: " action
    action="${action:-A}"
    action="-${action^^}"

    #Select chain
    read -r -p "Select Chain (INPUT, OUTPUT, FORWARD, custom) [INPUT]: " chain
    chain="${chain:-INPUT}"

    #Select Target
    
}

#====== FILE FUNCTIONS ======
reset_sys_file()
{
    if [ -e "$SYS_FILE" ]; then
        echo "existe"
        truncate -s 0 "$SYS_FILE"
    else
        touch "$SYS_FILE"
    fi
    printf "#!/bin/bash\n" > "$SYS_FILE"
}