#!/bin/bash

#====== VARIABLES ======
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
option=-1
tables=(filter nat mangle raw security)

#====== SOURCE FILES ======
source "$BASE_DIR/utils.sh"
source "$IPTABLES_FILE"
source "$SERVICE_FILE"

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
            rules_menu
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        fi

    done

    print_info "Exiting"
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
            print_info "Adding cleaning tables commands..." 2
            iptables_clean_all_rules
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        elif [ "$option" -eq 3 ]; then
            print_info "3" 2
        fi

    done

    option=-1
}

rules_menu()
{
    while [ "$option" -ne 0 ]; do
        clear
        print_rules_menu

        read -r -p "Select Option: " option

        if ! check_only_numbers "$option"; then
            print_error "Make sure that you selected a correct option" 2
            option=-1
            continue
        fi

        if [ "$option" -eq 1 ]; then
            print_info "Adding default rules commands..." 2
            iptables_default_rules
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        elif [ "$option" -eq 3 ]; then
            iptables_rule_wizzard
        fi

    done

    option=-1
}

#Check if exists systemd archive, if exists clean it, fi not create it
reset_sys_file

#Starts the program
main_menu