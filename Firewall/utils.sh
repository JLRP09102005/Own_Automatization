#!/bin/bash

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

check_yes_no_response()
{
    local response="${1,,}"

    [[ "$response" =~ ^y(es)?$ ]]
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
    [5] → Save Config
    [6] → Restore Config
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

print_services_menu()
{
    echo -e "${FG_GREEN}"
    cat << 'MENU'
     _____ _                        _ _ 
    |  ___(_)_ __ _____      ____ _| | |
    | |_  | | '__/ _ \ \ /\ / / _` | | |
    |  _| | | | |  __/\ V  V / (_| | | |
    |_|   |_|_|  \___| \_/\_/ \__,_|_|_|
                                        
    ═══════════════════════════════════════
    [1] → Move iptables file to system
    [2] → Create default service for iptables file
    [3] → Create personalized service
    [4] → Remove service for iptables file
    [5] → Start Service
    [6] → Stop Service
    [7] → Enable Service
    [8] → Disable Service
    [9] → File Preview
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

#====== USER & PERMISSIONS ======
check_root_privilegies()
{
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
      root_user=1
    fi
}