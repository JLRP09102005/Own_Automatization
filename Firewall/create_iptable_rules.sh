#!/bin/bash

#====== VARIABLES ======
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
option=-1
tables=(filter nat mangle raw security)

#====== SOURCE FILES ======
source "$BASE_DIR/utils.sh"

#====== FUNCTIONS ======
main_menu()
{
    while [ "$option" -ne 0 ]; do
        clear
        print_main_menu

        read -r -p "Select Option: " option

        if ! check_only_numbers "$option"; then
            print_error "Make sure that you selected a correct option" 2
            option=-1
            continue
        fi

        if [ "$option" -eq 1 ]; then
            clean_menu
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        fi

    done

    printf "Exiting"
    sleep 2
}

clean_menu()
{
    while [ "$option" -ne 0 ]; do
        clear
        print_clean_menu

        read -r -p "Select Option: " option

        if ! check_only_numbers "$option"; then
            print_error "Make sure that you selected a correct option" 2
            option=-1
            continue
        fi

        if [ "$option" -eq 1 ]; then
            iptables_clean_all_rules
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        fi

    done
}

#====== IPTABLES FUNCTIONS ======
##Clean Rules
iptables_clean_all_rules()
{
    for table in "${tables[@]}"; do
        sudo iptables -t "$table" -F
        sudo iptables -t "$table" -X
        sudo iptables -t "$table" -Z

        sudo ip6tables -t "$table" -F
        sudo ip6tables -t "$table" -X
        sudo ip6tables -t "$table" -Z
    done
}

# #====== Default Rules ======
# sudo iptables -P INPUT DROP
# sudo iptables -P OUTPUT ACCEPT
# sudo iptables -P FORWARD DROP

# sudo ip6tables -P INPUT DROP
# sudo ip6tables -P OUTPUT DROP
# sudo ip6tables -P FORWARD DROP

# sudo iptables -A INPUT -i lo -j ACCEPT #Grant local port access
# sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT #Allow full duplex connections and related relations from other connections
# sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP #Deny strange connections

# #====== SSH ======
# sudo iptables -t filter -A INPUT -i wlan0 -p tcp --dport 54321 -j ACCEPT

#Check if exists systemd archive, if exists clean it, fi not create it
if [ -e "$SYS_FILE" ]; then
    echo "existe"
    truncate -s 0 "$SYS_FILE"
else
    touch "$SYS_FILE"
fi

#Starts the program
main_menu